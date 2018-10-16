class AuthorizationCode < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  before_create do
    # random = SecureRandom.hex(32)
    random = SecureRandom.urlsafe_base64
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
      BCrypt::Engine.cost
    self.token = BCrypt::Password.create(random, cost: cost)
    UserMailer.with(user: user, token: random).authorization_code.deliver_now
  end

  # Sends authentication code email.
  # def send_authorization_code_email
  #   # UserMailer.password_reset(self).deliver_now
  #   UserMailer.with(user: user, authorization_code: self).authorization_code.deliver_now
  # end

  # Returns true if a password reset has expired.
  def authorization_code_expired?
    created_at < 2.hours.ago
  end


  # Returns the hash digest of the given string.
  # def self.digest(string)
  #   cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
  #     BCrypt::Engine.cost
  #   BCrypt::Password.create(string, cost: cost)
  # end

  # Returns true if the given token matches the digest.
  def authenticated?(token)
    digest = send("token")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def authorization_code_used
    update_attribute(:used_at, Time.zone.now)
  end

  def is_used?
    return false if used_at.nil?
    true
  end
end
