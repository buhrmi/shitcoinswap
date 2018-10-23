class Platform < ApplicationRecord
  after_find do
    self.extend "PlatformIntegrations::#{self.module}".constantize
  end

  def name
    
  end

  def network
    data['network']
  end

  def wallet_address
    data['wallet_address']
  end

  def enc_wallet_key
    data['enc_wallet_key']
  end

  def native_asset
    Asset.find_by(native_symbol: native_symbol)
  end
end
