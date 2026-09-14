class Wallet < ApplicationRecord
  JSON_OPTIONS = {
    only: [ :address ]
  }
  acts_as_sequenced scope: [ :user_id, :asset_id ]

  belongs_to :user
  belongs_to :asset

  has_many :deposits, dependent: :destroy

  before_create :generate_address

  scope :asset, ->(asset) { where(asset_id: asset.id) }

  def generate_address
    asset.assign_wallet_address(self)
  end
end
