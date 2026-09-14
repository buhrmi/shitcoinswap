# The Bitcoin token on the Bitcoin network. Addresses are derived from this
# asset's own extended public key; everything chain-wide (RPC, scan cursor)
# belongs to Network::Bitcoin.
class Asset::Bitcoin < Asset
  XPUB = Rails.application.credentials.dig(:bitcoin, :xpub) || "vpub5ZfbdassBjc5xD9jREby9HXNrt5mCxaeeryQ5jN12NJ2rDbzJSiWv1fphutd6DcgSJxfpr1Krp5HE3SFbMV8stLpKiNrcCx7JaxYTHVuWBS"

  ROOT = ::Bitcoin::ExtPubkey.from_base58(XPUB)

  def assign_wallet_address(wallet)
    # ROOT is at m/84'/0'/0'
    wallet.address = ROOT.derive(wallet.user_id).derive(wallet.sequential_id).addr
  end
end
