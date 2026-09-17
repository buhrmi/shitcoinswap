class Asset < ApplicationRecord
  JSON_OPTIONS = {
    only: [ :id, :name, :type ]
  }

  belongs_to :network, optional: true

  has_many :wallets, dependent: :destroy
  has_many :deposits, dependent: :destroy

  def assign_wallet_address(wallet)
    raise NoMethodError, "#{self.class.name} must implement the #assign_wallet_address method"
  end
end
