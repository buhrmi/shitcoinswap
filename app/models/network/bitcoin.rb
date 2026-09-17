class Network::Bitcoin < Network
  # How far back the very first scan reaches. Every later scan continues from
  # `last_scanned_height`, so once a chain has been picked up nothing is skipped.
  INITIAL_DEPTH = 6

  # Which chain this network is on, and the node it is read from. Both are
  # deployment configuration and live in `config` (see db/seeds.rb), so the same
  # code runs against mainnet, testnet or signet without the environment saying
  # which one.
  def chain
    config["chain"] or raise "#{name} has no chain configured"
  end

  def rpc_url
    config["rpc_url"] or raise "#{name} has no rpc_url configured"
  end

  # The extended public key addresses are derived from. A network on the real
  # chain keeps its key out of the database, so it is read from the credentials
  # the deployment holds instead.
  def xpub
    config["xpub"] || credential_xpub ||
      raise("#{name} has no xpub: set config.xpub, or networks.#{credential_name}.xpub in the credentials")
  end

  # Addresses are handed out by the network, because bitcoinrb keeps the chain
  # params in a global and they have to be in place both while the key is parsed
  # and while the address is encoded.
  def derive_address(user_id, index)
    with_chain_params { hd_root.derive(user_id).derive(index).addr }
  end

  # Kept per instance so one scan reuses a single client; assigning one is also
  # how tests stub the network.
  attr_writer :rpc

  def rpc
    @rpc ||= Rpc.new(rpc_url)
  end

  def tip_height
    @tip_height ||= rpc.getblockcount
  end

  # Scans the blocks that follow the last scanned one, records every output
  # paying one of our addresses as a Deposit and refreshes the confirmations of
  # the deposits that are still counting up.
  #
  #   network.scan_deposits            # continue where the last scan stopped
  #   network.scan_deposits(depth: 100)  # first scan: look 100 blocks back
  #   # => { from: 812_340, to: 812_345, created: 1, refreshed: 4, credited: 1 }
  def scan_deposits(depth: INITIAL_DEPTH)
    # The tip is read once per scan and reused for every block, so all the
    # confirmations in a report are measured against the same height.
    @tip_height = rpc.getblockcount

    from = (last_scanned_height || tip_height - depth) + 1
    report = { from: from, to: tip_height, created: 0, refreshed: 0, credited: 0 }

    from.upto(tip_height) { |height| scan_block(height, report) }
    report[:refreshed] = refresh_confirmations
    report[:credited] = credit_confirmed_deposits

    # Only ever move the cursor forward: a tip below it means we are talking to
    # a different chain, which must not make us scan the same blocks again.
    update!(last_scanned_height: tip_height) if tip_height > last_scanned_height.to_i

    report
  end

  private

  # Credentials name a network by the short name it goes by there, so the key of
  # Network::Bitcoin lives at networks.bitcoin.xpub.
  def credential_name
    type.demodulize.downcase
  end

  def credential_xpub
    Rails.application.credentials.dig(:networks, credential_name, :xpub)
  end

  # The chain params are global in bitcoinrb, so they are applied around the
  # operations that read them rather than once at boot. Assigning an unknown
  # chain raises, which is what a bad config should do.
  def with_chain_params
    ::Bitcoin.chain_params = chain.to_sym
    yield
  end

  # Parsed lazily and remembered: the version bytes of the key are matched
  # against the chain params, so this only works inside #with_chain_params.
  def hd_root
    @hd_root ||= ::Bitcoin::ExtPubkey.from_base58(xpub)
  end

  def scan_block(height, report)
    block_at(height)["tx"].each do |tx|
      tx["vout"].each_with_index do |output, index|
        wallet = wallets_by_address[address_of(output)]
        next unless wallet

        report[:created] += 1 if record_deposit(tx["txid"], index, output, wallet, height)
      end
    end
  end

  def record_deposit(txid, index, output, wallet, height)
    deposit = deposits.find_or_initialize_by(wallet: wallet, tx: txid, tx_idx: index)
    deposit.user_id = wallet.user_id
    deposit.asset_id = wallet.asset_id
    deposit.amount = BigDecimal(output["value"].to_s)
    deposit.block_height = height
    deposit.confirmations = confirmations_for(height)
    return false if deposit.persisted? && !deposit.changed?

    deposit.save!
    true
  end

  def confirmations_for(height)
    tip_height - height + 1
  end

  # A deposit that is still counting up is recounted from the block it came in,
  # so a payment keeps gaining confirmations after its block was scanned.
  #
  # Scoped by asset id instead of through the association: update_all on a
  # joined relation aliases the target table, which makes the recounted columns
  # ambiguous in Postgres.
  def refresh_confirmations
    Deposit.where(asset: assets).pending.where.not(block_height: nil)
      .where("confirmations <> ? - block_height + 1", tip_height)
      .update_all([ "confirmations = ? - block_height + 1", tip_height ])
  end

  def block_at(height)
    rpc.getblock(rpc.getblockhash(height), 2)
  end

  # Every wallet on this chain that we control, by address. Loaded once per scan
  # so a block full of outputs costs a single query.
  def wallets_by_address
    @wallets_by_address ||= wallets.index_by(&:address)
  end

  def address_of(vout)
    script = vout["scriptPubKey"] || {}
    [ script["address"], *script["addresses"] ].compact.first
  end

  # Minimal JSON-RPC client for the handful of calls a scan makes.
  #
  # bitcoinrb ships one, but it subclasses JSON::Pure::Parser (which json_pure
  # 3 no longer defines), defines its methods by calling `help` on the node when
  # it is constructed, and sets no timeouts - none of which suits a public
  # endpoint that is expected to be slow or briefly unavailable.
  class Rpc
    OPEN_TIMEOUT = 5
    READ_TIMEOUT = 60

    def initialize(url)
      @uri = URI.parse(url)
    end

    def getblockcount
      call("getblockcount")
    end

    def getblockhash(height)
      call("getblockhash", height)
    end

    def getblock(hash, verbosity = 2)
      call("getblock", hash, verbosity)
    end

    private

    def call(method, *params)
      response = Net::HTTP.start(
        @uri.hostname, @uri.port,
        use_ssl: @uri.scheme == "https",
        open_timeout: OPEN_TIMEOUT,
        read_timeout: READ_TIMEOUT
      ) { |http| http.request(request_for(method, params)) }

      raise "#{method} failed: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      payload = JSON.parse(response.body)
      raise "#{method} failed: #{payload['error']}" if payload["error"]

      payload["result"]
    end

    def request_for(method, params)
      request = Net::HTTP::Post.new(@uri, "content-type" => "application/json")
      request.basic_auth(@uri.user, @uri.password) if @uri.user
      request.body = JSON.generate(jsonrpc: "1.0", id: method, method: method, params: params)
      request
    end
  end
end
