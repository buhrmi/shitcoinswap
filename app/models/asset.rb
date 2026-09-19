class Asset < ApplicationRecord
  # contract_address and network_id are what a link to a token is built from. The network
  # is sent as an id alone: its config holds keys.
  JSON_OPTIONS = {
    only: [ :id, :name, :symbol, :contract_address, :network_id, :description ],
    include: {
      icon: {}
    }
  }

  belongs_to :network, optional: true

  has_many :wallets, dependent: :destroy
  has_many :deposits, dependent: :destroy

  has_one_attached :icon

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
