class Deposit < ApplicationRecord
  belongs_to :address, optional: true
  belongs_to :asset
  belongs_to :user
  belongs_to :withdrawal_to_hotwallet, class_name: 'Withdrawal', optional: true

  before_validation do
    self.user ||= address.user
  end

  after_create do
    user.adjust_balance!(asset, amount, self)
    UserMailer.with(user: user, deposit: self).deposit_email.deliver_later
  end

  def tx_url
    asset.platform.tx_url(transaction_id)
  end
end
