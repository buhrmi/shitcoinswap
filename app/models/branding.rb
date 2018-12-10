class Branding < ApplicationRecord
  has_one_attached :logo

  def self.default
    @default ||= Branding.find(1)
  end
end
