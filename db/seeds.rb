# A network is a chain; assets are the tokens on it. Which chain it is - the
# chain params, the node it is read from, and the key addresses are derived from
# - lives in the row instead of the environment.
bitcoin = Network::Bitcoin.find_or_initialize_by(name: "Bitcoin")
bitcoin.config = {
  # No xpub: the network on the real chain reads its key from the credentials.
  chain: "mainnet",
  rpc_url: "https://bitcoin-rpc.publicnode.com"
}
bitcoin.save!

Asset::Bitcoin.find_or_create_by!(name: "Bitcoin", network: bitcoin)

if Rails.env.development?
  # Testnet as well, so deposits can be played with without spending real coins.
  # The key is a throwaway wallet.
  test_btc = Network::Bitcoin.find_or_initialize_by(name: "Bitcoin Testnet")
  test_btc.config = {
    chain: "testnet",
    rpc_url: "https://bitcoin-testnet-rpc.publicnode.com",
    xpub: "vpub5ZfbdassBjc5xD9jREby9HXNrt5mCxaeeryQ5jN12NJ2rDbzJSiWv1fphutd6DcgSJxfpr1Krp5HE3SFbMV8stLpKiNrcCx7JaxYTHVuWBS"
  }
  test_btc.save!

  Asset::Bitcoin.find_or_create_by!(name: "test-btc", network: test_btc)
end

platform = Asset.where(name: "Jeseph's Booking Platform").first_or_create!

platform.description = "Years in the making, Jeseph's platform is set to breath new life into the Japanese nightlife industry."
platform.save!
