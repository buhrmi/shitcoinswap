hot_wallet = Eth::Key.new
eth_hot_wallet_key = Utils.encrypt_key(hot_wallet.private_hex)
eth_hot_wallet_address = hot_wallet.address

eth_platform_main    = Platform.where(native_symbol: 'ETH').first_or_create!(module: 'ETH', data: {network: 'mainnet', hot_wallet_address: eth_hot_wallet_address, enc_hot_wallet_key: eth_hot_wallet_key})
eth_platform_classic = Platform.where(native_symbol: 'ETC').first_or_create!(module: 'ETH', native_symbol: 'ETC', data: {network: 'classic', hot_wallet_address: eth_hot_wallet_address, enc_hot_wallet_key: eth_hot_wallet_key})

unless Rails.env.production?
  eth_platform_rinkeby = Platform.where(native_symbol: 'ETR').first_or_create!(module: 'ETH', native_symbol: 'ETR', data: {network: 'rinkeby', hot_wallet_address: eth_hot_wallet_address, enc_hot_wallet_key: eth_hot_wallet_key})
end

supported_coins= [{
  address: '0xECC3A47F5d0AC33db287D8f9DeBf03830853Cbb9',
  platform: eth_platform_main
},
{
  address: '0x39013f961c378f02c2b82a6e1d31e9812786fd9d',
  platform: eth_platform_main
},
{
  address: '0x1f77db6ecbce65902d8e27888b40d344f45c337e',
  platform: eth_platform_main
},
{
  address: '0x268F39ebB4868a09FA654D4fFE1Ab024bc937Db2',
  platform: eth_platform_main
},
{
  address: '0x7ef8eeD38c44f5952b65D9C778EED74807FdD12c',
  platform: eth_platform_main
},
{
  address: '0x15C23ea5939420e2301952f85Dd26176a72AeC89',
  platform: eth_platform_main
},
{
  address: '0x45038b67b1B55D7E3E142eec49Ce6bd2254c4e57',
  platform: eth_platform_main
},
{
  address: '0x88B2469f8464A3B83E02C99F7766Ed933d9AF570',
  platform: eth_platform_main
},
{
  address: '0x6932497EA8635E959b78b38cEe4B20eF04d77f79',
  platform: eth_platform_main
}]

for coin_info in supported_coins
  Coin.where(coin_info).first_or_create!
end