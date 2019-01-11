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

  def balance_of(asset, address)
    if asset.native? # Get balance of native ETH
      params = [
        address,
        'latest'
      ]
      eth_result_to_number(jsonrpc('eth_getBalance', params)['result'])
    else # Get balance of token
      signature = Eth::Utils.bin_to_hex(Eth::Utils.keccak256('balanceOf(address)')).first(8)
      data = '0x' + signature + hex_to_param(address)
      params = [
        {
          to: asset.address,
          data: data
        },
        'latest'
      ]
      eth_result_to_number(jsonrpc('eth_call', params)['result']) || 0
    end
  end


  def scan_for_deposits!(from = nil, to = nil)
    latest_block = get_block_number - REQUIRED_CONFIRMATIONS
    self.last_scanned_block ||= latest_block
    
    from = last_scanned_block + 1 unless from
    to = latest_block unless to

    # SCAN EACH BLOCK INDIVIDUALLY FOR ETH DEPOSITS
    for block in (from .. to)
      block_hex = '0x' + block.to_s(16)
      transactions = fetch_block(block_hex)['transactions']
      puts "\nFETCHING BLOCK "+block.to_s
      create_deposits_from_transactions! transactions
    end
    
  end

  def name
    if network == 'main'
      'Bitcoin'
    else
      "Bitcoin (Test)"
    end
  end

  def create_deposits_from_transactions! transactions
    for transaction in transactions
      to_address = transaction['to']
      sender_address = transaction['from']
      next unless to_address
      # If the deposit comes from our own wallet address, ignore it. It is probably a transfer to fund the fee for erc20-to-wallet transfer
      next if sender_address.downcase == wallet_address.downcase
      amount = transaction['value'].last(64).to_i(16).to_f / 10 ** 18
      hash = transaction['hash']
      address = Address.where(module: self.module, address: to_address.downcase).first
      if address
        deposit = address.deposits.create!(transaction_id: hash, amount: amount, asset: self.native_asset)
        puts "Deposit: #{deposit}"
      else
        print '.'
      end
    end
  end

  
end