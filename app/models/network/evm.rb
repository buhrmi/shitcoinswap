# An account-based chain (Tron, Ethereum, ...). A key is an account here, and its address
# is the last 20 bytes of keccak-256 over the public key - the same twenty bytes on both
# chains, written down differently.
#
# Only the contract tells one token from another, since a transfer is just a payment to an
# address the holder already has. Where a block's transfers are read from is the chain's
# business (#transfers_in): contract calls on Tron, logs on Ethereum.
class Network::Evm < Network
  # The first four bytes of keccak-256("transfer(address,uint256)"), the ABI every token on
  # these chains follows for a transfer.
  TRANSFER_SELECTOR = "a9059cbb"

  # The deposit address of a user's nth wallet: the account index is the user, the address
  # index the wallet within it - the same shape as on Bitcoin.
  def derive_address(user_id, index)
    with_chain_params do
      encode_address(account_address(hd_root.derive(user_id).derive(index).pub))
    end
  end

  # What a contract says about itself: the three things every token on these chains knows.
  def token_metadata(contract)
    metadata = {
      "name" => string_return(call_contract(contract, "name()")),
      "symbol" => string_return(call_contract(contract, "symbol()")),
      "decimals" => uint_return(call_contract(contract, "decimals()"))
    }.compact
    raise "contract does not report token metadata" if metadata.empty?

    metadata
  end

  private

  # Reads a contract function without changing anything. The answer is ABI-encoded the same
  # way on every chain, so only the call itself is the chain's business.
  def call_contract(contract, signature)
    raise NotImplementedError, "#{self.class} does not implement #call_contract"
  end

  # A string comes back as an offset, its length, and then the bytes themselves.
  def string_return(hex)
    return if hex.nil?

    length = hex[64, 64].to_i(16)
    return if length.zero?

    [ hex[128, length * 2] ].pack("H*").force_encoding(Encoding::UTF_8)
  end

  # A number is a single 32 byte word.
  def uint_return(hex)
    hex&.to_i(16)
  end

  # Records a deposit for every transfer in the block that pays one of our
  # wallets through the contract of an asset we track.
  def scan_block(height, report)
    transfers_in(block_at(height)).each do |transfer|
      wallets_for(transfer).each do |wallet|
        created = record_deposit(
          tx: transfer[:tx], tx_idx: transfer[:tx_idx], wallet: wallet,
          amount: wallet.asset.amount_from(transfer[:amount]), height: height
        )
        report[:created] += 1 if created
      end
    end
  end

  # The transfers a block holds, each as { tx:, tx_idx:, contract:, to:, amount: },
  # with `to` encoded the way this chain writes addresses.
  def transfers_in(block)
    raise NotImplementedError, "#{self.class} does not implement #transfers_in"
  end

  # A transfer belongs to the asset whose contract was called, and one address can
  # hold several tokens at once.
  def wallets_for(transfer)
    wallets_by_address[transfer[:to]].to_a.select { |wallet| wallet.asset.contract_address == transfer[:contract] }
  end

  # Reads the recipient and the amount out of transfer(address,uint256) calldata,
  # or nil when the call is something else. The recipient sits in the tail of the
  # first 32 byte word, the amount in the second.
  def transfer_in(calldata)
    data = calldata.to_s
    return unless data.start_with?(TRANSFER_SELECTOR)

    { to: [ data[32, 40] ].pack("H*"), amount: data[72, 64].to_i(16) }
  end

  # keccak-256 over the uncompressed public key, without its 0x04 prefix. Both
  # Ethereum and Tron keep the last 20 bytes of that hash as the address.
  def account_address(compressed_pubkey)
    point = ::Bitcoin::Key.new(pubkey: compressed_pubkey).to_point
    uncompressed = ECDSA::Format::PointOctetString.encode(point, compression: false)
    Digest::Keccak.digest(uncompressed[1..], 256)[-20..]
  end

  # How a chain writes those 20 bytes down: hex for Ethereum, base58check with a
  # version byte for Tron.
  def encode_address(bytes)
    raise NotImplementedError, "#{self.class} does not implement #encode_address"
  end
end
