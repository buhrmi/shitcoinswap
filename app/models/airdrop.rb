class Airdrop < ApplicationRecord
  belongs_to :user
  belongs_to :asset

  validates_presence_of :memo

  validate do
    total_amount = 0
    available = asset.in_wallet - asset.sum_balances
    recipients.each do |r| 
      errors.add(:amounts, "#{r[0]} has invalid amount") if r[1].to_f <= 0
      errors.add(:amounts, "email #{r[0]} is invalid") unless r[0].match URI::MailTo::EMAIL_REGEXP
      total_amount +=r [1].to_f
    end
    # errors.add(:amounts, "total can't be more than #{available}") if total_amount > available
  end

  def recipients
    recipients = amounts.lines.map(&:split)
  end

  def execute!
    validate!
    self.executed_at = Time.now
    for recipient in recipients
      user = User.find_or_create_by! email: recipient[0]
      adjustment = BalanceAdjustment.create!(user: user, asset: asset, amount: recipient[1].to_f, memo: memo, change: self)
      UserMailer.with(user: user, adjustment: adjustment).airdrop.deliver_later
    end
  end
end
