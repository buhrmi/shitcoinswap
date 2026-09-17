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

  # Assets are looked up by their ticker, and a Bitcoin asset has no contract to
  # read one from, so the symbol and the name are both stated here.
  test_btc = Asset::Bitcoin.find_or_initialize_by(symbol: "TBTC", network: btc_testnet)
  test_btc.name = "test-btc"
  test_btc.save!
end

btc = Asset::Bitcoin.find_or_initialize_by(symbol: "BTC", network: btc_mainnet)
btc.name = "Bitcoin"
btc.save!

# A token is found by the contract it lives in, and its name, symbol and decimals are
# read from that contract when the row is created - so there is nothing else to say
# about it here.
usdt = Asset::Evm.find_or_initialize_by(contract_address: "TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t", network: tron_mainnet)
usdt.description = "An unregulated money-laundering vehicle allegedly pegged to the U.S. dollar"
usdt.save!

jeseph = Asset.where(name: "Jeseph's Booking Platform").first_or_create!

jeseph.description = "Years in the making, Jeseph's platform is set to breathe new life into the Japanese nightlife industry."
jeseph.save!
