# Ethereum: the same account addresses as Tron, written in hex. Deposits would be ERC-20
# transfer logs, which nothing reads yet, so a scan of one raises.
class Network::Ethereum < Network::Evm
  private

  def encode_address(bytes)
    "0x" + bytes.unpack1("H*")
  end
end
