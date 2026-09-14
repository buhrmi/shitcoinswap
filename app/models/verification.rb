# frozen_string_literal: true

# A one-time email verification for the signup flow. Created when a visitor
# submits an email address on /users/new; the 5-digit code is emailed out and
# the record is confirmed on /verifications/:id before the account is created.
#
# No session state is involved: the DB row is the single source of truth, so
# the code-entry page can be reloaded, or opened from a fresh request, and
# still line up with the same identity.
#
# State is derived entirely from timestamps: a record is *verified* once
# +verified_at+ is set, and *expired* once +expires_at+ has passed.
class Verification < ApplicationRecord
  EXPIRES_AFTER = 10.minutes

  before_validation :set_defaults, on: :create

  validates :kind, inclusion: { in: %w[email] }
  validates :code, presence: true, format: { with: /\A\d{5}\z/ }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :pending, -> { where(verified_at: nil).where("expires_at > ?", Time.current) }

  def verified?
    verified_at.present?
  end

  def expired?
    expires_at.past?
  end

  # Validates +entered_code+ and, when correct and not expired, marks the
  # verification as verified. Returns a Symbol outcome for the controller.
  def confirm!(entered_code)
    return :expired if expired?
    return :wrong_code unless code == entered_code.to_s.strip

    update!(verified_at: Time.current)
    :verified
  end

  # Re-submitting an email drops any earlier, still-pending verification for
  # the same address so only the most recently issued code works.
  def self.expire_pending_for!(email)
    where(email: email).pending.delete_all
  end

  private

  def set_defaults
    self.kind ||= "email"
    self.code ||= rand(10_000..99_999).to_s
    self.expires_at ||= EXPIRES_AFTER.from_now
  end
end
