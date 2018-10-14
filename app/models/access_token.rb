class AccessToken < ApplicationRecord
  belongs_to :user
  
  before_create do
    self.token = SecureRandom.hex(32)
  end
end
