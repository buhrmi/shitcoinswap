class AuthorizationCode < ApplicationRecord
  belongs_to :user
  
  before_create do
    self.code = random = SecureRandom.hex(32)
  end

  def expired?
    created_at < 2.hours.ago
  end

  def trade_for_token!
    update_attributes! used_at: Time.now
    user.create_access_token!
  end

  def used?
    used_at
  end
end
