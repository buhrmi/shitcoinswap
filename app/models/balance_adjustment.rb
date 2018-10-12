class BalanceAdjustment < ApplicationRecord
  belongs_to :user
  belongs_to :asset
  belongs_to :change, polymorphic: true

  validate do
    if amount < 0 && user.available_balance(asset) + amount < 0
      errors.add(:amount, "would make balance negative")
    end
  end
end
