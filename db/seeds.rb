btc_mainnet = Network::Bitcoin.find_or_initialize_by(name: "Bitcoin")

btc_mainnet.config = {
  # No xpub: the network on the real chain reads its key from the credentials.
  chain: "mainnet",
  rpc_url: "https://bitcoin-rpc.publicnode.com"
}
btc_mainnet.save!

tron_mainnet = Network::Tron.find_or_initialize_by(name: "TRON")

tron_mainnet.config = {
  # No xpub: the network on the real chain reads its key from the credentials.
  chain: "mainnet",
  rpc_url: "https://api.trongrid.io"
}
tron_mainnet.save!

if Rails.env.development?
  # Testnet as well, so deposits can be played with without spending real coins.
  # The key is a throwaway wallet.
  btc_testnet = Network::Bitcoin.find_or_initialize_by(name: "Bitcoin Testnet")
  btc_testnet.config = {
    chain: "testnet",
    rpc_url: "https://bitcoin-testnet-rpc.publicnode.com",
    xpub: "vpub5ZfbdassBjc5xD9jREby9HXNrt5mCxaeeryQ5jN12NJ2rDbzJSiWv1fphutd6DcgSJxfpr1Krp5HE3SFbMV8stLpKiNrcCx7JaxYTHVuWBS"
  }
  btc_testnet.save!

  Asset::Bitcoin.find_or_create_by!(name: "test-btc", network: btc_testnet)
end

btc = Asset::Bitcoin.find_or_create_by!(name: "Bitcoin", network: btc_mainnet)

usdt = Asset::Evm.find_or_create_by!(name: "USDT (Tron)", network: tron_mainnet)
usdt.config = { contract: "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t", decimals: 6 }
usdt.description = "An unregulated money-laundering vehicle allegedly pegged to the U.S. dollar"
usdt.save!

jeseph = Asset.where(name: "Jeseph's Booking Platform").first_or_create!

jeseph.description = "Years in the making, Jeseph's platform is set to breathe new life into the Japanese nightlife industry."
jeseph.save!
