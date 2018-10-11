class Withdrawal < ApplicationRecord
  belongs_to :coin
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

    # The below code will ensure that we have enough native coins in the customer's deposit address to cover the transfer of deposited tokens
    # to our hotwallet after customer deposited tokens
    if unfunded? && was_first_try? && !coin.native? && !from_hotwallet?
      puts "Withdrawal #{id} unfunded. Sending funds from hotwallet."
      native_coin = coin.platform.native_coin
      # This will create a transfer from the hot wallet to the sender_address to cover for the token transfer fee
      Withdrawal.create!(receiver_address: sender_address, amount: coin.transfer_fee + native_coin.transfer_fee, coin: native_coin)
    end
  end

  def from_hotwallet?
    sender_address.nil?
  end

  def ensure_balance_adjustment_present
    self.balance_adjustment ||= BalanceAdjustment.new({user: user, coin: coin, amount: -amount})
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

  def tx_url
    coin.platform.tx_url(transaction_id)
  end

  def check_receiver_address
    errors.add(:receiver_address, 'is invalid') unless Eth::Address.new(receiver_address).valid?
  end

  def check_amount
    errors.add(:amount, 'must be higher than transfer fee') if amount < coin.user_transfer_fee
  end

  def execute!
    return unless status.nil? || status == 'error'

    platform = coin.platform
    id, hex = platform.build_signed_transfer_tx(coin, amount, receiver_address, sender_address)
    self.transaction_id = id
    self.signed_transaction = hex
    self.status = 'pending'
    save!
     
    self.tries += 1
    platform.submit_signed_tx!(hex)
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
