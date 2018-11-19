class Asset < ApplicationRecord
  translates :description
  translates :page_content

  belongs_to :platform
  has_many :cached_volumes, foreign_key: 'base_asset_id'

  has_many :balance_adjustments
  has_many :orders, foreign_key: 'base_asset_id'
  has_many :base_trades, class_name: 'Trade', foreign_key: 'base_asset_id'
  belongs_to :submitter, class_name: 'User', optional: true

  validate :check_address
  validates_presence_of :name
  validates_uniqueness_of :address, case_sensitive: false, allow_nil: true
  
  before_validation :fetch_platform_data
  before_save :sanitize_page

  has_one_attached :logo
  has_one_attached :background
  has_one_attached :whitepaper_en

  has_many_attached :files

  before_save do
    self.address.downcase! if self.address
  end
  
  def self.eth
    find_by(native_symbol: 'ETH')
  end

  def self.with_24h_volume_cache(quote_asset_id)
    joins("inner join cached_volumes on base_asset_id = assets.id and cached_volumes.id = (select id from cached_volumes where base_asset_id = assets.id and period = '24h' and quote_asset_id = #{quote_asset_id} order by created_at desc limit 1)")
  end

  def self.rinkeby
    find_by(native_symbol: 'ETH(rinkeby)')
  end

  def self.quotable_ids
    quotable.pluck(:id)
  end

  def self.quotable
    where(native_symbol: ['ETH', 'JPY', 'ETH(rinkeby)'])
  end

  # This is the fee paid in native platform shitasset, for example gas price for transfering erc20 tokens
  def transfer_fee
    if platform
      platform.transfer_fee_for(self).to_f
    else
      0
    end
  end

  def sanitize_page
    return unless page_content
    for content in page_content
      content['html'] = Sanitize.fragment(content['html'], Sanitize::Config::WHITELISTED)
    end
  end
  # This is the fee that the user has to pay in the currency that he is transferring. not neccesarily native currency
  def user_transfer_fee
    if platform
      platform.user_transfer_fee_for(self).to_f
    else
      0
    end
  end
  
  def managable_by? user
    # If an asset does not have a submitter, it can be managed by anyone
    return true unless submitter
    
    return user && (user.admin? || submitter == user)
  end

  def check_address
    return if native?
    errors.add(:address, 'not valid') unless platform.valid_address?(address)
  end

  def in_wallet
    platform.balance_of(self, platform.wallet_address).to_f / unit
  end

  def sum_balances
    balance_adjustments.sum(:amount)
  end

  def total_supply
    return unless platform
    return if native?
    platform_data['total_supply'].to_f / unit
  end

  def fetch_platform_data
    return unless new_record? or address_changed? or platform_id_changed?
    return unless platform
    return unless address.present?
    return if native?
    platform.fetch_platform_data_for(self)
  end

  def explorer_url
    platform.try(:explorer_url_for, self)
  end

  def wallet_url(wallet)
    platform.try(:wallet_url_for, self, wallet)
  end
  
  def symbol
    native_symbol || platform_data['symbol']
  end

  def volume_24h quote_asset = platform.native_asset
    Trade.where(base_asset: self, quote_asset: quote_asset).where('created_at > ?', 24.hours.ago).sum('amount * price')
  end

  def buy_price quote_asset = platform.native_asset
    Order.open.where(base_asset: self, quote_asset: quote_asset, side: 'sell', kind: 'limit').order('price asc').first.try(:price)
  end

  def sell_price quote_asset = platform.native_asset
    Order.open.where(base_asset: self, quote_asset: quote_asset, side: 'buy', kind: 'limit').order('price desc').first.try(:price)
  end

  def unit
    10 ** (platform_data['decimals'] || 0)
  end

  def native?
    self.native_symbol
  end

  def sum_balances
    balance_adjustments.sum(:amount)
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def price_chart_data quote_asset_id
    # TODO: show open/close prices instead average prices
    charts = base_trades.where(quote_asset_id: quote_asset_id).select('first(price order by created_at), last(price order by created_at), max(price) as high, min(price) as low, avg(price) as avg, sum(price * amount) as volume').group_by_day(:created_at)
  end

  def hourly_prices(quote_asset_id, since = 7.days.ago)
    base_trades.where(quote_asset_id: quote_asset_id).group_by_hour(:created_at).where('created_at > ?', since).average(:price)
  end
end
