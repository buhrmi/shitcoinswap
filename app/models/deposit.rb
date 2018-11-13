class Deposit < ApplicationRecord
  belongs_to :address, optional: true
  belongs_to :asset
  belongs_to :user
  has_one :balance_adjustment, as: :change

  belongs_to :withdrawal_to_wallet, class_name: 'Withdrawal', optional: true

  before_validation do
    self.user ||= address.user
    self.balance_adjustment ||= BalanceAdjustment.new({user: user, asset: asset, amount: amount})
  end

  after_create_commit do
    UserMailer.with(user: user, deposit: self).deposit_email.deliver_later
  end

  def transaction_url
    asset.platform.transaction_url(transaction_id)
  end
end
