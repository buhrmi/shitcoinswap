class User < ApplicationRecord
  attr_accessor :reset_token

  has_secure_password

  # Verify that email field is not blank and that it doesn't already exist in the db (prevents duplicates):
  validates :email, presence: true, uniqueness: true

  passwordless_with :email

  has_many :balance_adjustments
  has_many :withdrawals
  has_many :sessions

  def create_session!
    Session.create!(user: self)
  end

  def available_balance coin
    balance_adjustments.where(coin: coin).sum(:amount)
  end

  def admin?
    true
  end

  def balances
    balance_adjustments.group(:coin_id).sum(:amount).as_json
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest,  User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end


  # Returns the hash digest of the given string.
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
      BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  private

end
