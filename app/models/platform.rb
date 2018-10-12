class Platform < ApplicationRecord
  after_find do
    self.extend "PlatformIntegrations::#{self.module}".constantize
  end

  def network
    data['network']
  end

  def hot_wallet_address
    data['hot_wallet_address']
  end

  def enc_hot_wallet_key
    data['enc_hot_wallet_key']
  end

  def native_coin
    Coin.find_by(native_symbol: native_symbol)
  end
end
