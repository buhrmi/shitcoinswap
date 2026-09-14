# A network is a chain; assets are the tokens on it.
bitcoin = Network.where(name: "Bitcoin", type: "Network::Bitcoin").first_or_create!

Asset.where(name: "Bitcoin", type: "Asset::Bitcoin").first_or_create!(network: bitcoin)
