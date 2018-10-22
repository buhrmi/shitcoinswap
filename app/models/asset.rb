class Asset < ApplicationRecord
  ETH = find_by(native_symbol: 'ETH')
  JPY = find_by(native_symbol: 'JPY')

  translates :description

  belongs_to :platform
  has_many :balance_adjustments
  belongs_to :submitter, class_name: 'User', optional: true

  validate :check_address
  validates_uniqueness_of :address, case_sensitive: false, allow_nil: true
  
  before_save :fetch_platform_data

  before_save do
    self.address.downcase! if self.address
  end
   
  # This is the fee paid in native platform shitasset, for example gas price for transfering erc20 tokens
  def transfer_fee
    if platform
      platform.transfer_fee_for(self).to_f
    else
      0
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

  def check_address
    return if native?
    errors.add(:address, 'not valid') unless platform.valid_address?(address)
  end

  def total_supply
    return unless platform
    return if native?
    return 1000 if Rails.env.development?
    @last_checked ||= 0
    if Time.now > @last_checked + 60.seconds
      @last_checked = Time.now
      @total_supply = (platform.fetch_total_supply(self) || 0).to_f / unit
    else
      @total_supply
    end
    
  end

  def fetch_platform_data
    return unless new_record? or address_changed? or platform_id_changed?
    return unless platform
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
