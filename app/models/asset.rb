class Asset < ApplicationRecord
  translates :description
  translates :page_content

  belongs_to :platform
  has_many :balance_adjustments
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

  def self.quotable_ids
    where(native_symbol: ['ETH', 'JPY']).pluck(:id)
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
    platform_data['symbol']
  end

  def volume24h
    Trade.where(base_asset: self).where('created_at > ?', 24.hours.ago).sum('amount * rate')
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
end
