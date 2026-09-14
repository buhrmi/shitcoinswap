# frozen_string_literal: true

# A single-use password reset token. Only a SHA-256 digest of the token is
# stored so a database leak doesn't expose live reset links. The plaintext
# token (SecureRandom.base58(24)) is generated on demand and sent over email.
class PasswordReset < ApplicationRecord
  TOKEN_EXPIRY = 1.hour

  belongs_to :user

  scope :active, -> { where(used_at: nil).where(expires_at: Time.current..) }

  # Creates a reset for the user and returns the plaintext token to email out.
  # Any previously issued, still-active resets for the same user are
  # invalidated so only the most recent link works.
  def self.generate_for(user)
    user.password_resets.active.update_all(used_at: Time.current)

    token = SecureRandom.base58(24)
    create!(
      user: user,
      token_digest: digest(token),
      expires_at: TOKEN_EXPIRY.from_now
    )
    token
  end

  # Finds an unused, unexpired reset by its plaintext token.
  def self.find_by_token(token)
    active.find_by(token_digest: digest(token))
  end

  # Marks the reset as used so the token can't be reused.
  def consume!
    update!(used_at: Time.current)
  end

  def self.digest(token)
    Digest::SHA256.base64digest(token)
  end
end
