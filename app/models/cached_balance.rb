class CachedBalance < ApplicationRecord
  belongs_to :user
  belongs_to :asset

  default_scope do
    order('total desc')
  end

  def self.cache!(user, asset)
    total = user.asset_balance(asset)
    available = total - user.asset_in_orders(asset)
    find_or_create_by!(user: user, asset: asset).update_attributes(total: total, available: available)
  end
end
