class Pair < ApplicationRecord
  JSON_OPTIONS = {
    include: {
      base_asset: Asset::JSON_OPTIONS,
      quote_asset: Asset::JSON_OPTIONS
    }
  }

  belongs_to :base_asset, class_name: "Asset"
  belongs_to :quote_asset, class_name: "Asset"
end
