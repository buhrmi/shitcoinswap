###
# CREATE ETHEREUM PLATFORMS AND KEYS AND INITIAL SUPPORTED TOKENS
#
wallet = Eth::Key.new
eth_wallet_key = Utils.encrypt_key(wallet.private_hex)
eth_wallet_address = wallet.address

eth_platform_main    = Platform.where(native_symbol: 'ETH').first_or_create!(module: 'ETH', data: {network: 'mainnet', wallet_address: eth_wallet_address, enc_wallet_key: eth_wallet_key})
eth_platform_classic = Platform.where(native_symbol: 'ETC').first_or_create!(module: 'ETH', data: {network: 'classic', wallet_address: eth_wallet_address, enc_wallet_key: eth_wallet_key})

admin = User.where(admin: true, email: 'dj@shitcoin.jp').first_or_create!

supported_assets= [{
  address: '0xECC3A47F5d0AC33db287D8f9DeBf03830853Cbb9',
  platform_id: eth_platform_main.id,
  submitter_id: admin.id
  featured_at: Time.now
},
{
  address: '0x39013f961c378f02c2b82a6e1d31e9812786fd9d',
  platform_id: eth_platform_main.id
  submitter_id: admin.id
},
{
  address: '0x1f77db6ecbce65902d8e27888b40d344f45c337e',
  platform_id: eth_platform_main.id,
  submitter_id: admin.id
  featured_at: Time.now
},
{
  address: '0x268F39ebB4868a09FA654D4fFE1Ab024bc937Db2',
  platform_id: eth_platform_main.id
  submitter_id: admin.id
},
{
  address: '0x7ef8eeD38c44f5952b65D9C778EED74807FdD12c',
  platform_id: eth_platform_main.id
  submitter_id: admin.id
},
{
  address: '0x15C23ea5939420e2301952f85Dd26176a72AeC89',
  platform_id: eth_platform_main.id
  submitter_id: admin.id
},
{
  address: '0x45038b67b1B55D7E3E142eec49Ce6bd2254c4e57',
  platform_id: eth_platform_main.id
  submitter_id: admin.id
},
{
  address: '0x88B2469f8464A3B83E02C99F7766Ed933d9AF570',
  platform_id: eth_platform_main.id
  submitter_id: admin.id
},
{
  address: '0x6932497EA8635E959b78b38cEe4B20eF04d77f79',
  platform_id: eth_platform_main.id
  submitter_id: admin.id
}]

eth = Asset.where(native_symbol: 'ETH').first_or_create!(name: 'Ethereum', platform: eth_platform_main, platform_data: {decimals: 18, symbol: 'ETH', name: 'Ethereum'}) 
etc = Asset.where(native_symbol: 'ETC').first_or_create!(name: 'Ethereum (classic)', platform: eth_platform_classic, platform_data: {decimals: 18, symbol: 'ETC', name: 'Ethereum Classic'})

unless Rails.env.production?
  eth_platform_rinkeby = Platform.where(native_symbol: 'ETH(rinkeby)').first_or_create!(module: 'ETH', data: {network: 'rinkeby', wallet_address: eth_wallet_address, enc_wallet_key: eth_wallet_key})
  supported_assets << {
    address: '0x1c15fb22128f06888963a12441e917c059f53e2b',
    platform_id: eth_platform_rinkeby.id
    submitter_id: admin.id
  }
  ethrinkeby = Asset.where(native_symbol: 'ETH(rinkeby)').first_or_create!(name: 'Ethereum (rinkeby)', platform: eth_platform_rinkeby, platform_data: {decimals: 18, symbol: 'ETH(rinkeby)', name: 'Ethereum (Rinkeby)'})
end

for asset_info in supported_assets
  asset_info[:address].downcase!
  Asset.where(asset_info).first_or_create!
end
