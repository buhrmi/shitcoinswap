class AccessToken < ApplicationRecord
  belongs_to :user
  
  before_create do
    self.token = SecureRandom.hex(32)
  end

  def self.active
    where(logged_out_at: nil)
  end
end
