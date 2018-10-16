class User < ApplicationRecord
  # Verify that email field is not blank and that it doesn't already exist in the db (prevents duplicates):
  validates :email, presence: true, uniqueness: true
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_uniqueness_of :email

  has_many :balance_adjustments
  has_many :withdrawals
  has_many :access_tokens
  has_many :addresses
  has_many :authorization_codes

  def create_access_token!
    AccessToken.create!(user: self)
  end

  def available_balance asset
    balance_adjustments.where(asset: asset).sum(:amount)
  end

  def admin?
    true
  end

  def display_name
    email.split('@').first
  end

  def balances
    balance_adjustments.group(:asset_id).sum(:amount).to_hash
  end
end
