class Withdrawal < ApplicationRecord
  belongs_to :asset
  belongs_to :user, optional: true
  has_one :balance_adjustment, as: :change
  
  validates_numericality_of :amount, greater_than: 0
  validate :check_amount
  validates_presence_of :receiver_address
  validate :check_receiver_address
  before_validation :ensure_balance_adjustment_present, if: :has_user?
  validates_associated :balance_adjustment

  after_update_commit do
    if user and status == 'submitted' and [nil, 'error'].include?(attribute_before_last_save('status'))
      UserMailer.with(user: user, withdrawal: self).withdrawal_submitted_email.deliver_later
    end

    # The below code will ensure that we have enough native assets in the customer's deposit address to cover the transfer of deposited tokens
    # to our hotwallet after customer deposited tokens
    if unfunded? && was_first_try? && !asset.native? && !from_hotwallet?
      puts "Withdrawal #{id} unfunded. Sending funds from hotwallet."
      native_asset = asset.platform.native_asset
      # This will create a transfer from the hot wallet to the sender_address to cover for the token transfer fee
      Withdrawal.create!(receiver_address: sender_address, amount: asset.transfer_fee + native_asset.transfer_fee, asset: native_asset)
    end
  end

  def from_hotwallet?
    sender_address.nil?
  end

  def ensure_balance_adjustment_present
    self.balance_adjustment ||= BalanceAdjustment.new({user: user, asset: asset, amount: -amount})
  end

  def has_user?
    user
  end

  def was_first_try?
    tries == 1 && attribute_before_last_save('tries') == 0 
  end

  def unfunded?
    # TODO: find a better way to check this
    self.error == 'insufficient funds for gas * price + value' # This error text comes from infura.io
  end

  def transaction_url
    asset.platform.transaction_url(transaction_id)
  end

  def check_receiver_address
    errors.add(:receiver_address, 'is invalid') unless Eth::Address.new(receiver_address).valid?
  end

  def check_amount
    errors.add(:amount, 'must be higher than transfer fee') if amount < asset.user_transfer_fee
  end

  def execute!
    return unless status.nil? || status == 'error'

    platform = asset.platform
    tx_id, raw_tx_hex = platform.create_raw_tx(asset, amount, receiver_address, sender_address)
    self.transaction_id = tx_id
    self.signed_transaction = raw_tx_hex
    save!
     
    self.tries += 1
    platform.submit_raw_tx!(raw_tx_hex)
    self.submitted_at = Time.now
    self.status = 'submitted'
    self.error = nil
    self.error_at = nil
  rescue StandardError => e
    self.status = 'error'
    self.error = e.message
    self.error_at = Time.now
  ensure
    save!
  end

end
