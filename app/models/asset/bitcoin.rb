# The Bitcoin token on a Bitcoin network (mainnet, testnet, ...). Everything
# chain-wide - the node, the scan cursor, and the key addresses are derived from
# - belongs to Network::Bitcoin, which is why the address is asked for there.
class Asset::Bitcoin < Asset
  def assign_wallet_address(wallet)
    wallet.address = network.derive_address(wallet.user_id, wallet.sequential_id)
  end
end
