# The extended public key wallet addresses are derived from: the real one in
# production, the testnet key everywhere else.
xpub = if Rails.env.production?
  Rails.application.credentials.dig(:bitcoin, :xpub) ||
    raise("missing the bitcoin.xpub credential")
else
  "vpub5ZfbdassBjc5xD9jREby9HXNrt5mCxaeeryQ5jN12NJ2rDbzJSiWv1fphutd6DcgSJxfpr1Krp5HE3SFbMV8stLpKiNrcCx7JaxYTHVuWBS"
end

# bitcoinrb is configured globally too, so the chain has to be picked before any
# class derives from that key. The key decides which chain: a mainnet key only
# parses on mainnet, a testnet one (vpub/tpub) only on testnet, so the two
# cannot drift apart.
::Bitcoin.chain_params = %i[mainnet testnet signet].find do |candidate|
  ::Bitcoin.chain_params = candidate
  begin
    ::Bitcoin::ExtPubkey.from_base58(xpub)
    true
  rescue ArgumentError
    false
  end
end || raise("bitcoin.xpub does not belong to a chain bitcoinrb knows")

# Every wallet address is derived from here; HD_ROOT sits at m/84'/0'/0'.
HD_ROOT = ::Bitcoin::ExtPubkey.from_base58(xpub)
