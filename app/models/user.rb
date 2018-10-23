class User < ApplicationRecord
  # Verify that email field is not blank and that it doesn't already exist in the db (prevents duplicates):
  validates :email, presence: true, uniqueness: true
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_uniqueness_of :email

  has_many :balance_adjustments
  has_many :withdrawals
  has_many :access_tokens
  has_many :addresses
  has_many :authorization_codes
  has_many :orders
  has_many :cached_balances

  def create_access_token!
    AccessToken.create!(user: self)
  end

  def available_balance asset
    asset_balance(asset) - asset_in_orders(asset)
  end

  def asset_balance asset
    BigDecimal.new(balance_adjustments.where(asset: asset).sum(:amount).to_s)
  end

  def asset_in_orders asset
    # Pending sell orders
    pending_sell = orders.open.where(side: 'sell', base_asset: asset).sum('quantity - quantity_filled')

    # Pending buy limit orders
    pending_buy_limit = orders.open.where(kind: 'limit', side: 'buy', quote_asset: asset).sum('(quantity - quantity_filled) * rate')
    
    # Pending buy market orders
    pending_buy_market = orders.open.where(kind: 'market', side: 'buy', quote_asset: asset).sum('total - total_used')

    BigDecimal.new(pending_sell.to_s) + pending_buy_limit + pending_buy_market
  end

  def display_name
    email.split('@').first
  end

  def cached_balances_json
    # returns a json string similar to {"1": {"available": .., "total": ...}, ...}
    cached_balances.group_by(&:asset_id).map { |k, v| [k, v.first] }.to_h.to_json
  end

end
