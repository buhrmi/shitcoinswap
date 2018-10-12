module PlatformIntegrations::ETH
  REQUIRED_CONFIRMATIONS = 1

  def self.new_address_attributes
    key = Eth::Key.new
    return {
      enc_private_key: Utils.encrypt_key(key.private_hex),
      public_key: key.public_hex,
      address: key.address.downcase
    }
  end

  def add_checksum(address)
    Eth::Utils.format_address address
  end

  def fetch_new_transfers from_block, to_block
    topic = '0x' + Eth::Utils.bin_to_hex(Eth::Utils.keccak256('Transfer(address,address,uint256)'))
    params = [{
      topics: [topic],
      toBlock: to_block,
      fromBlock: from_block
    }]
    jsonrpc('eth_getLogs', params)['result']
  end

  def get_nonce(address, block = 'latest')
    params = [address, block]
    eth_result_to_number jsonrpc('eth_getTransactionCount', params)['result']
  end

  def get_block_number
    jsonrpc('eth_blockNumber')['result'].last(-2).to_i(16)
  end

  def fetch_block block_hex
    params = [block_hex, true]
    jsonrpc('eth_getBlockByNumber', params)['result']
  end

  def scan_for_deposits!
    latest_block = get_block_number - REQUIRED_CONFIRMATIONS
    self.last_scanned_block ||= latest_block
    
    # SCAN EACH BLOCK INDIVIDUALLY FOR ETH DEPOSITS
    for block in (last_scanned_block + 1 .. latest_block)
      block_hex = '0x' + block.to_s(16)
      transactions = fetch_block(block_hex)['transactions']
      puts "\nFETCHING BLOCK "+block.to_s
      create_deposits_from_transactions! transactions
    end
    
    # SCAN FOR TOKENS
    from_block = '0x' + (last_scanned_block + 1).to_s(16)
    to_block = '0x' + latest_block.to_s(16)
    puts "\nSEARCHING TOKEN TRANSFERS FROM " + (last_scanned_block + 1).to_s + " TO " + latest_block.to_s
    new_transactions = fetch_new_transfers(from_block, to_block)
    check_transfers_for_deposits(new_transactions)

    self.last_scanned_block = latest_block
    save!
  end

  def name
    if network == 'mainnet'
      'Ethereum'
    else
      "Ethereum (#{network})"
    end
  end

  def create_deposits_from_transactions! transactions
    for transaction in transactions
      to_address = transaction['to']
      sender_address = transaction['from']
      next unless to_address
      next if sender_address.downcase == hot_wallet_address.downcase # sometimes we need to fund the address to transfer erc20 tokens
      amount = transaction['value'].last(64).to_i(16).to_f / 10 ** 18
      hash = transaction['hash']
      address = Address.where(platform_id: self.id, address: to_address.downcase).first
      if address
        deposit = address.deposits.create!(transaction_id: hash, amount: amount, asset: self.native_asset)
        puts "Deposit: #{deposit}"
      else
        print '.'
      end
    end
  end

  def int_to_param(int)
    int.to_s(16).rjust(64, '0')
  end

  def hex_to_param(hex)
    hex.gsub('0x','0').rjust(64, '0')
  end

  def gas_price
    30_000_000_000 # lets make it nice and fast
  end

  def transfer_fee_for(asset)
    if asset == native_asset
      (21000 * gas_price).to_f / native_asset.unit
    else
      (105000 * gas_price).to_f / native_asset.unit
    end
  end

  def user_transfer_fee_for(asset)
    if asset == native_asset
      (21000 * gas_price).to_f / native_asset.unit
    else
      0
    end
  end

  def valid_address?(address)
    address.present? && Eth::Address.new(address).valid?
  end

  def build_signed_transfer_tx(asset, amount, to_address, sender_address)
    sender_address ||= hot_wallet_address
    
    if asset == native_asset
      # Eth transfer
      gas_limit = 21000
      fee = gas_limit * gas_price
      params = {
        # TODO: store limits in platform database row
        data: '',
        gas_limit: gas_limit,
        gas_price: gas_price,
        nonce: get_nonce(sender_address),
        to: to_address,
        from: sender_address,
        value: (amount * asset.unit).to_i - fee
      }
      tx = Eth::Tx.new(params)
    else
      # Token transfer
      # '0xa9059cbb' == Eth::Utils.bin_to_hex(Eth::Utils.keccak256('transfer(address,uint256)')).first(8)
      data = '0xa9059cbb' + hex_to_param(to_address) + int_to_param((amount * asset.unit).to_i)
      tx = Eth::Tx.new({
        data: data,
        # TODO: store limits in platform database row
        gas_limit: 100_000,
        gas_price: gas_price,
        nonce: get_nonce(sender_address),
        to: asset.address,
        from: sender_address,
        value: 0
      })
    end
    tx.sign(private_key_for(sender_address))
    return tx.id, tx.hex
  end

  def private_key_for(sender_address)
    if sender_address == hot_wallet_address
      Eth::Key.new priv: Utils.decrypt_key(enc_hot_wallet_key)
    else
      enc_private_key = Address.where(address: sender_address.downcase).first.try(:enc_private_key)
      Eth::Key.new priv: Utils.decrypt_key(enc_private_key)
    end
  end

  # Rule of thumb: only throw on IO error. we do not care whether or not the tx is mined within a given time
  def submit_signed_tx!(hex)
    body = jsonrpc('eth_sendRawTransaction', [hex])
    raise body['error']['message'] if body['error']
  end

  def jsonrpc(method, params = [])
    data = {
      id: 1,
      jsonrpc: '2.0',
      method: method,
      params: params
    }
    headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
    response = Typhoeus.post(jsonrpc_url, body: data.to_json, headers: headers)
    JSON.parse(response.body)
  end

  def check_transfers_for_deposits transactions
    for transaction in transactions
      contract = transaction['address']
      next unless transaction['topics'].length == 3 # require that from and to are indexed
      to_address = '0x' + transaction['topics'][2].last(40)
      address = Address.where(platform: self.id, address: to_address.downcase).first
      if address
        # create asset if it doesnt exist
        asset = asset.where(platform: self.id, address: contract.downcase).first_or_create!
        hash = transaction['transactionHash']
        amount = transaction['data'].last(64).to_i(16).to_f / asset.unit
        address.with_lock do
          deposit = Deposit.create!(address: address, transaction_id: hash, amount: amount, asset: asset)
          puts "Deposit: #{deposit.inspect}"
        end
      else
        print '.'
      end
    end
  end

  def fetch_total_supply(asset)
    total_supply = hydra_eth_call(asset.address, 'totalSupply()').run
    asset.platform_data[:total_supply] = eth_result_to_number(JSON.parse(total_supply.response_body)['result'])
  end

  def fetch_platform_data_for(asset)
    # Using hydra to run all these requests in parallel
    hydra = Typhoeus::Hydra.hydra
    symbol = hydra_eth_call(asset.address, 'symbol()')
    name = hydra_eth_call(asset.address, 'name()')
    decimals = hydra_eth_call(asset.address, 'decimals()')
    total_supply = hydra_eth_call(asset.address, 'totalSupply()')
    hydra.queue(symbol)
    hydra.queue(name)
    hydra.queue(decimals)
    hydra.queue(total_supply)
    hydra.run
    platform_data = {
      symbol: eth_result_to_string(JSON.parse(symbol.response.body)['result']),
      name: eth_result_to_string(JSON.parse(name.response.body)['result']),
      decimals: eth_result_to_number(JSON.parse(decimals.response.body)['result']),
      total_supply: eth_result_to_number(JSON.parse(total_supply.response.body)['result'])
    }
    asset.platform_data = platform_data
    asset.name = platform_data[:name]
    platform_data
  end

  # calls an Ethereum contract through infura
  def hydra_eth_call address, signature, params = []
    params = [
      {
        to: address,
        data: '0x'+Digest::SHA3.hexdigest(signature, 256).first(8)
      },
      'latest'
    ]
    data = {
      id: 1,
      jsonrpc: '2.0',
      method: 'eth_call',
      params: params
    }
    Typhoeus::Request.new(jsonrpc_url, {
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: data.to_json,
      method: :post
    })
  end
  
  def jsonrpc_url
    if network == 'classic'
      "https://ethereumclassic.network"
    else
      "https://#{network}.infura.io"
    end
  end

  def tx_url(transaction_id)
    return '' unless transaction_id
    if network == 'mainnet'
      "https://etherscan.io/tx/#{transaction_id}"
    elsif network == 'classic'
      "https://gastracker.io/tx/#{transaction_id}"
    else
      "https://#{data['network']}.etherscan.io/tx/#{transaction_id}"
    end
  end

  def explorer_url_for(asset)
    if network == 'mainnet'
      "https://etherscan.io/token/#{asset.address}"
    elsif network == 'classic'
      "https://gastracker.io/token/#{asset.address}"
    else
      "https://#{data['network']}.etherscan.io/token/#{asset.address}"
    end
  end

  def wallet_url_for(asset, wallet)
    if asset == native_asset
      if network == 'mainnet'
        "https://etherscan.io/address/#{wallet}"
      elsif network == 'classic'
        "https://gastracker.io/addr/#{wallet}"
      else
        "https://#{data['network']}.etherscan.io/address/#{wallet}"
      end
    else
      if network == 'mainnet'
        "https://etherscan.io/token/#{asset.address}?a=#{wallet}"
      elsif network == 'classic'
        "https://gastracker.io/token/#{asset.address}/#{wallet}"
      else
        "https://#{data['network']}.etherscan.io/token/#{asset.address}?a=#{wallet}"
      end
    end
  end

  # Takes the last 32 bytes and converts them to integer
  def eth_result_to_number result
    result.gsub("0x", '').last(64).to_i(16)
  end
  
  # Takes the last 32 bytes, converts them to ascii, removes all 0-padding
  def eth_result_to_string result
    [result.last(64)].pack('H*').force_encoding('UTF-8').gsub("\x00", '')
  end
end