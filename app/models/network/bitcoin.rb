class Network::Bitcoin < Network
  # Addresses are handed out by the network, because bitcoinrb keeps the chain
  # params in a global and they have to be in place both while the key is parsed
  # and while the address is encoded.
  def derive_address(user_id, index)
    with_chain_params { hd_root.derive(user_id).derive(index).addr }
  end

  def tip_height
    rpc.getblockcount
  end

  # Kept per instance so one scan reuses a single client; assigning one is also
  # how tests stub the network.
  attr_writer :rpc

  def rpc
    @rpc ||= Rpc.new(rpc_url)
  end

  def tip_height
    rpc.getblockcount
  end

  # Kept per instance so one scan reuses a single client; assigning one is also
  # how tests stub the network.
  attr_writer :rpc

  def rpc
    @rpc ||= Rpc.new(rpc_url)
  end

  private

  def scan_block(height, report)
    block_at(height)["tx"].each do |tx|
      tx["vout"].each_with_index do |output, index|
        # A UTXO belongs to one address, and an address to one wallet.
        wallet = wallets_by_address[address_of(output)]&.first
        next unless wallet

        created = record_deposit(
          tx: tx["txid"], tx_idx: index, wallet: wallet,
          amount: wallet.asset.amount_from(output["value"]), height: height
        )
        report[:created] += 1 if created
      end
    end
  end

  def block_at(height)
    rpc.getblock(rpc.getblockhash(height), 2)
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
