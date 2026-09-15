# The Bitcoin token on the Bitcoin network. Addresses are derived from HD_ROOT
# (see config/initializers/bitcoin.rb); everything chain-wide (RPC, scan cursor)
# belongs to Network::Bitcoin.
class Asset::Bitcoin < Asset
  def assign_wallet_address(wallet)
    # HD_ROOT is at m/84'/0'/0'
    wallet.address = HD_ROOT.derive(wallet.user_id).derive(wallet.sequential_id).addr
  end
end
