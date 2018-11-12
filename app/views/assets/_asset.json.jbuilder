json.extract! asset, :id, :symbol, :name
json.markets do
  json.eth do
    json.volume_24h asset.volume_24h(Asset.eth)
    json.buy_price asset.buy_price(Asset.eth)
    json.sell_price asset.sell_price(Asset.eth)
  end
  json.rinkeby do
    json.volume_24h asset.volume_24h(Asset.rinkeby)
    json.buy_price asset.buy_price(Asset.rinkeby)
    json.sell_price asset.sell_price(Asset.rinkeby)
  end
end
json.url asset_url(asset, format: :json)
