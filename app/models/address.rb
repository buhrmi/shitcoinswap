class Address < ApplicationRecord
  belongs_to :user
  
  has_many :deposits

  def platform_integration
    "PlatformIntegrations::#{self.module}".constantize
  end

  before_create do
    assign_attributes platform_integration.new_address_attributes
  end
end
