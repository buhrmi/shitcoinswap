class Trade < ApplicationRecord
  belongs_to :buyer, class_name: 'User'
  belongs_to :seller, class_name: 'User'
  belongs_to :buy_order, class_name: 'Order'
  belongs_to :sell_order, class_name: 'Order'
  belongs_to :base_coin, class_name: 'Coin'
  belongs_to :quote_coin, class_name: 'Coin'

  def self.by(user)
    where('buyer_id = ? or seller_id = ?', user.id, user.id)
  end

  def self.for(coin)
    where(base_coin_id: coin)
  end
end
