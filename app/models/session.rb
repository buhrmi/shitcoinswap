class Session < ApplicationRecord
  belongs_to :user
  
  before_create do
    self.authorization = SecureRandom.hex(64)
  end
end
