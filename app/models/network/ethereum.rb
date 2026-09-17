# Ethereum: the same account addresses as Tron, written in hex. Reading deposits
# here means reading ERC-20 transfer logs, which is not implemented - nothing
# uses Ethereum yet, so a scan of one raises.
class Network::Ethereum < Network::Evm
  private

  def encode_address(bytes)
    "0x" + bytes.unpack1("H*")
  end
end
