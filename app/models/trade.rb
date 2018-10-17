class Trade < ApplicationRecord
  belongs_to :buyer, class_name: 'User'
  belongs_to :seller, class_name: 'User'
  belongs_to :buy_order, class_name: 'Order'
  belongs_to :sell_order, class_name: 'Order'
  belongs_to :base_asset, class_name: 'Asset'
  belongs_to :quote_asset, class_name: 'Asset'
  has_many :balance_adjustments, as: :change

  def self.by(user)
    where('buyer_id = ? or seller_id = ?', user.id, user.id)
  end

  def self.for(asset)
    where(base_asset_id: asset)
  end
end
