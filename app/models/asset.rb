class Asset < ApplicationRecord
  JSON_OPTIONS = {
    only: [ :id, :name, :type ]
  }

  belongs_to :network, optional: true

  has_many :wallets, dependent: :destroy
  has_many :deposits, dependent: :destroy

  # A wallet's address belongs to the chain the deposits arrive on, so the network
  # hands it out: the account index is the user and the address index is the wallet
  # within it. Every kind of chain works that way, which is why this is not left to
  # the subclasses.
  def assign_wallet_address(wallet)
    network or raise "#{name} is on no network, so it has no address to give a wallet"

    wallet.address = network.derive_address(wallet.user_id, wallet.sequential_id)
  end

  # What a chain's raw value means in this asset's units: a Bitcoin node reports
  # coins, while a token reports whole numbers in its smallest unit. That does
  # differ per chain, so it stays with the subclass.
  def amount_from(raw)
    raise NoMethodError, "#{self.class.name} must implement the #amount_from method"
  end
end
