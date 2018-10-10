class Platform < ApplicationRecord
  DEFAULT_PLATFORM = where(native_symbol: 'ETH').first

  after_find do
    self.extend "PlatformIntegrations::#{self.module}".constantize
  end

  def native_coin
    Coin.where(symbol: native_symbol)
  end

  def default
    self == DEFAULT_PLATFORM
  end
end
