# A token on an account chain (Tron, Ethereum, ...). The token itself is a
# contract, and every token on the chain is paid to the address its holder has
# there, so the address comes from the network while the contract says which
# transfers are this asset's business. The token standards on those chains
# (TRC-20, ERC-20) all read a contract the same way, which is why one class
# covers the lot.
class Asset::Evm < Asset
  # The address of the contract the token lives in.
  def contract
    config.to_h["contract"] or raise "#{name} has no contract configured"
  end

  # Token amounts are whole numbers in the smallest unit, so a token with six
  # decimals reports 12.75 as 12750000.
  def decimals
    config.to_h.fetch("decimals", 0)
  end

  def amount_from(raw)
    BigDecimal(raw.to_s) / 10**decimals
  end
end
