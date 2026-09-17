class Asset::Bitcoin < Asset
  # A Bitcoin node reports output values in whole coins already.
  def amount_from(raw)
    BigDecimal(raw.to_s)
  end
end
