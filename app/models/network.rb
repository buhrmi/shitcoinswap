# A network is a chain (Bitcoin, Ethereum, ...). The assets on it are the tokens,
# which is why anything chain-wide - RPC access, the height we have scanned up
# to - lives here instead of on the assets.
class Network < ApplicationRecord
  has_many :assets, dependent: :destroy
  has_many :wallets, through: :assets
  has_many :deposits, through: :assets

  # Walks the blocks that follow `last_scanned_height`, records the deposits it
  # finds and returns a report. Each chain knows how to read its own blocks.
  def scan_deposits
    raise NotImplementedError, "#{self.class} does not implement #scan_deposits"
  end

  # Adds the deposits on this chain that are confirmed and not credited yet to
  # their user's balances. Returns how many were credited. A scan ends with a
  # recount, so this is what turns a payment into money.
  def credit_confirmed_deposits
    Deposit.where(asset: assets).credit_confirmed!
  end
end
