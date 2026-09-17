# A network is a chain (Bitcoin, Tron, ...). The assets on it are the tokens,
# which is why anything chain-wide - configuration, RPC access, the height we
# have scanned up to - lives here instead of on the assets.
class Network < ApplicationRecord
  # How far back the very first scan reaches. Later scans continue from `last_scanned_height`,
  # so nothing is skipped once a chain has been picked up; faster chains override this.
  INITIAL_DEPTH = 6

  has_many :assets, dependent: :destroy
  has_many :wallets, through: :assets
  has_many :deposits, through: :assets

  # The chain it is on, the node it is read from and the key addresses come from are all
  # deployment configuration, kept in the row (see db/seeds.rb) so the same code runs
  # against any chain without the environment saying which one.
  def chain
    config["chain"] or raise "#{name} has no chain configured"
  end

  def rpc_url
    config["rpc_url"] or raise "#{name} has no rpc_url configured"
  end

  # A network on the real chain keeps its key out of the database, so it is read
  # from the credentials the deployment holds instead.
  def xpub
    config["xpub"] || credential_xpub ||
      raise("#{name} has no xpub: set config.xpub, or networks.#{credential_name}.xpub in the credentials")
  end

  # The height of the newest block on the chain, read once at the start of a scan.
  def tip_height
    raise NotImplementedError, "#{self.class} does not implement #tip_height"
  end

  # Walks the blocks that follow `last_scanned_height`, records the deposits it finds,
  # recounts the ones still counting up and credits the confirmed ones. A chain supplies
  # #tip_height and #scan_block.
  #
  #   network.scan_deposits              # continue where the last scan stopped
  #   network.scan_deposits(depth: 100)  # first scan: look 100 blocks back
  #   # => { from: 812_340, to: 812_345, created: 1, refreshed: 4, credited: 1 }
  def scan_deposits(depth: INITIAL_DEPTH)
    # The tip is read once per scan and reused for every block, so all the
    # confirmations in a report are measured against the same height.
    @tip_height = tip_height

    from = (last_scanned_height || @tip_height - depth) + 1
    report = { from: from, to: @tip_height, created: 0, refreshed: 0, credited: 0 }

    from.upto(@tip_height) { |height| scan_block(height, report) }
    report[:refreshed] = refresh_confirmations
    report[:credited] = credit_confirmed_deposits

    # Only ever move the cursor forward: a tip below it means we are talking to
    # a different chain, which must not make us scan the same blocks again.
    update!(last_scanned_height: @tip_height) if @tip_height > last_scanned_height.to_i

    report
  end

  # What turns a payment into money: adds the deposits that are confirmed and not credited
  # yet to their users' balances and returns how many were credited.
  def credit_confirmed_deposits
    Deposit.where(asset: assets).credit_confirmed!
  end

  private

  # Reads one block and records the payments in it - outputs on a UTXO chain, token
  # transfers on an account chain.
  def scan_block(height, report)
    raise NotImplementedError, "#{self.class} does not implement #scan_block"
  end

  def record_deposit(tx:, tx_idx:, wallet:, amount:, height:)
    deposit = deposits.find_or_initialize_by(wallet: wallet, tx: tx, tx_idx: tx_idx)
    deposit.user_id = wallet.user_id
    deposit.asset_id = wallet.asset_id
    deposit.amount = amount
    deposit.block_height = height
    deposit.confirmations = confirmations_for(height)
    return false if deposit.persisted? && !deposit.changed?

    deposit.save!
    true
  end

  def confirmations_for(height)
    @tip_height - height + 1
  end

  # Recounted from the block it came in, so a payment keeps gaining confirmations after
  # its block was scanned.
  #
  # Scoped by asset id instead of through the association: update_all on a joined
  # relation aliases the target table, which makes the recounted columns ambiguous in
  # Postgres.
  def refresh_confirmations
    Deposit.where(asset: assets).pending.where.not(block_height: nil)
      .where("confirmations <> ? - block_height + 1", @tip_height)
      .update_all([ "confirmations = ? - block_height + 1", @tip_height ])
  end

  # Every wallet we control on this chain, by address, loaded once per scan. One address
  # can map to several wallets: every token on an account chain pays that same address.
  def wallets_by_address
    @wallets_by_address ||= wallets.group_by(&:address)
  end

  # Credentials name a network by the short name it goes by there, so the key of
  # Network::Bitcoin lives at networks.bitcoin.xpub.
  def credential_name
    type.demodulize.downcase
  end

  def credential_xpub
    Rails.application.credentials.dig(:networks, credential_name, :xpub)
  end

  # bitcoinrb keeps the chain params in a global, and the key's version bytes decide which
  # chain it belongs to, so they are applied around the parsing and derivation that read them.
  def with_chain_params
    ::Bitcoin.chain_params = chain.to_sym
    yield
  end

  # Parsed lazily and remembered: the key's version bytes are matched against the chain
  # params, so this only works inside #with_chain_params.
  def hd_root
    @hd_root ||= ::Bitcoin::ExtPubkey.from_base58(xpub)
  end
end
