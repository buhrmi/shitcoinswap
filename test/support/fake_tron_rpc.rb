# Stands in for a Tron node, so a scan can be driven without one. Blocks that were not
# set up come back empty.
class FakeTronRpc
  attr_accessor :height

  def initialize(height:)
    @height = height
    @blocks = {}
  end

  # Adds a block holding one TRC-20 transfer of `contract`'s token to `to`, a
  # base58 address, the way the node reports it.
  def with_transfer(height, to:, contract:, value:, status: "SUCCESS")
    block = (@blocks[height] ||= [])
    block << {
      "txID" => "tx-#{height}-#{block.size}",
      "ret" => [ { "contractRet" => status } ],
      "raw_data" => {
        "contract" => [ {
          "type" => "TriggerSmartContract",
          "parameter" => {
            "value" => {
              "contract_address" => contract,
              "data" => "a9059cbb#{"0" * 24}#{payload_hex(to)}#{"%064x" % value}"
            }
          }
        } ]
      }
    }
    self
  end

  def getnowblock
    height
  end

  def getblockbynum(num)
    { "transactions" => @blocks[num] || [] }
  end

  # Sets up what a constant call on the token at `address` answers, with the
  # values ABI-encoded the way the node encodes them. Leaving one out means the
  # contract says nothing about it.
  def with_token_metadata(address, name: nil, symbol: nil, decimals: nil)
    (@metadata ||= {})[address_hex(address)] = {
      "name()" => name && string_return(name),
      "symbol()" => symbol && string_return(symbol),
      "decimals()" => decimals && "%064x" % decimals
    }
    self
  end

  # Raising for a contract that was never set up keeps a call the test did not
  # expect from quietly answering with nothing.
  def call_contract(contract_hex, signature)
    answers = @metadata&.fetch(contract_hex, nil) or
      raise "no constant call was set up for #{signature} on #{contract_hex}"

    answers[signature]
  end

  private

  # offset (32 bytes), length (32 bytes), then the string itself, padded out to a
  # whole number of 32 byte words.
  def string_return(value)
    hex = value.unpack1("H*").ljust((value.bytesize + 31) / 32 * 64, "0")
    "%064x%064x%s" % [ 32, value.bytesize, hex ]
  end

  # A base58 T-address in the node's own two forms: the whole 21 byte address,
  # which is what it is asked about, and the bare 20 bytes that a transfer carries
  # in its calldata.
  def address_hex(address)
    ::Bitcoin::Base58.decode(address)[0, 42]
  end

  def payload_hex(address)
    ::Bitcoin::Base58.decode(address)[2, 40]
  end
end
