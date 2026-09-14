# bitcoinrb is configured globally, so the chain has to be picked before any
# class derives an address from an extended key.
#
# The key decides which chain that is: a mainnet key (xpub/zpub) only parses on
# mainnet, a testnet one (tpub/vpub) only on testnet, and the two have to agree.
# So follow the configured key, and fall back to the environment's default when
# there is none. BTC_NETWORK=mainnet|testnet|signet overrides.
key = Rails.application.credentials.dig(:bitcoin, :xpub)

chain = if ENV["BTC_NETWORK"].present?
  ENV["BTC_NETWORK"]
elsif key
  %i[mainnet testnet signet].find do |candidate|
    ::Bitcoin.chain_params = candidate
    begin
      ::Bitcoin::ExtPubkey.from_base58(key)
      true
    rescue ArgumentError
      false
    end
  end
else
  Rails.env.production? ? :mainnet : :testnet
end

::Bitcoin.chain_params = chain.to_sym
