class CachedVolume < ApplicationRecord
  belongs_to :base_asset, class_name: 'Asset'
  belongs_to :quote_asset, class_name: 'Asset'
end
