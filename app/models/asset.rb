class Asset < ApplicationRecord
  JSON_OPTIONS = {
    only: [ :id, :name, :symbol, :type ]
  }

  belongs_to :network, optional: true

  has_many :wallets, dependent: :destroy
  has_many :deposits, dependent: :destroy

  # The address belongs to the chain, so the network hands it out: the account index is the
  # user, the address index the wallet within it.
  def assign_wallet_address(wallet)
    network or raise "#{name} is on no network, so it has no address to give a wallet"

    wallet.address = network.derive_address(wallet.user_id, wallet.sequential_id)
  end

  # What a chain's raw value means in this asset's units: whole coins from a Bitcoin node,
  # an integer in the smallest unit from a token.
  def amount_from(raw)
    raise NoMethodError, "#{self.class.name} must implement the #amount_from method"
  end
end
