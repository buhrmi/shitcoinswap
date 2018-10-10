class BalanceAdjustment < ApplicationRecord
  belongs_to :user
  belongs_to :coin
  belongs_to :change, polymorphic: true
end
