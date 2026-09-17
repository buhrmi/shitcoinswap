# The Bitcoin token on a Bitcoin network (mainnet, testnet, ...). Everything
# chain-wide - the node, the scan cursor, and the key addresses are derived from
# - belongs to Network::Bitcoin, which is why the address is asked for there.
class Asset::Bitcoin < Asset
  # A Bitcoin node reports output values in whole coins already.
  def amount_from(raw)
    BigDecimal(raw.to_s)
  end
end
