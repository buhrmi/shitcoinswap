class Asset::Evm < Asset
  validates :contract_address, presence: true

  before_create :read_contract

  def amount_from(raw)
    BigDecimal(raw.to_s) / 10**decimals
  end

  private

  # Only fills in what the row does not already say, so a token that is fully described never
  # reaches the chain.
  def read_contract
    return if name.present? && symbol.present? && !decimals.nil?

    metadata = network.token_metadata(contract_address)
    raise "#{contract_address} does not answer name(), symbol() or decimals()" if metadata.empty?

    self.name = metadata["name"] if name.blank?
    self.symbol = metadata["symbol"] if symbol.blank?
    self.decimals = metadata["decimals"] if metadata["decimals"]
  end
end
