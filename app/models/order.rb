class Order < ActiveRecord::Base
  belongs_to :user
  has_many :trades
  belongs_to :base_asset, class_name: 'Asset'
  belongs_to :quote_asset, class_name: 'Asset'

  validates_numericality_of :quantity, greater_than: 0, unless: :buy_market?
  validates_numericality_of :total, greater_than: 0, if: :buy_market?
  validates_numericality_of :rate, greater_than: 0, unless: :market?
  validates_inclusion_of :kind, in: ['limit', 'market']
  validates_inclusion_of :side, in: ['sell', 'buy']
  validates_inclusion_of :quote_asset_id, in: [Asset::ETH.id]
  
  validate :ensure_assets_dont_match
  
  before_save do
    self.filled_at = Time.now if self.filled? and not self.filled_at
  end
  
  after_save do
    # This will throw an exception if the available balance is negative and thus roll back the transaction that we are inside
    user.validate_balance! base_asset
    user.validate_balance! quote_asset
  end
  
  after_commit do
    # TODO: push realtime updates to users
  end
  
  def self.open
    where(cancelled_at: nil, filled_at: nil)
  end
  
  def self.base(asset)
    where(base_asset: asset)
  end
  
  def self.quote(asset)
    where(quote_asset: asset)
  end
  
  
  def self.matching(order)
    orders = Order.where(base_asset: order.base_asset, quote_asset: order.quote_asset)
    orders = orders.where(kind: order.matching_kinds)
    
    if order.sell?
      orders = orders.where(side: 'buy').order('rate DESC')
      orders = orders.where("rate >= ? or kind = ?", order.rate, 'market') if order.limit?
    else
      orders = orders.where(side: 'sell').order('rate ASC')
      orders = orders.where("rate <= ? or kind = ?", order.rate, 'market') if order.limit?
    end
    
    return orders
  end
  
  def process!
    matching_orders = Order.lock.open.matching(self)
    
    for matching_order in matching_orders
      break if self.filled?
      self.fill!(matching_order)
    end
  end
  
  def filled?
    if self.buy_market?
      self.total_used >= self.total
    else
      self.quantity_filled >= self.quantity
    end
  end
  
  def unfilled_quantity(rate)
    if self.buy_market?
      (self.total - self.total_used) / rate
    else
      self.quantity - self.quantity_filled
    end
  end
  
  def fill!(other_order)
    rate = self.market? ? other_order.rate : self.rate
    
    quantity_to_fill = [self.unfilled_quantity(rate), other_order.unfilled_quantity(rate)].min
    
    sell_order = self.sell? ? self : other_order
    buy_order  = self.buy?  ? self : other_order
    
    base_change  = quantity_to_fill
    quote_change = quantity_to_fill * rate
    
    sell_order.total_used      += quote_change
    sell_order.quantity_filled += base_change
    buy_order.total_used       += quote_change
    buy_order.quantity_filled  += base_change
    
    other_order.save!
    self.save!

    trade = Trade.create!(quote_asset: quote_asset, base_asset: base_asset, buy_order: buy_order, sell_order: sell_order, buyer: buy_order.user, seller: sell_order.user, quantity: quantity_to_fill, rate: rate)
    
    # Adjust balances
    buy_order.user.adjust_balance!(base_asset,  base_change, trade)
    sell_order.user.adjust_balance!(quote_asset, quote_change, trade)
    sell_order.user.adjust_balance!(base_asset,  -base_change, trade)
    buy_order.user.adjust_balance!(quote_asset, -quote_change, trade)
  end
  
  def matching_kinds
    if self.market?
      ['limit']
    else
      ['market', 'limit']
    end
  end
  
  def buying_asset
    self.buy? ? base_asset : base_asset
  end

  def selling_asset
    self.sell? ? base_asset : quote_asset
  end

  def base_unit
    base_asset.unit
  end
  
  def quote_unit
    quote_asset.unit
  end
  
  def limit?
    kind == 'limit'
  end
  
  def market?
    kind == 'market'
  end
  
  def sell?
    side == 'sell'
  end
  
  def buy?
    side == 'buy'
  end
  
  def buy_market?
    buy? && market?
  end

  def ensure_assets_dont_match
    errors.add(:base_asset, "cant be the same as quote asset") if base_asset_id == quote_asset_id
  end
end
