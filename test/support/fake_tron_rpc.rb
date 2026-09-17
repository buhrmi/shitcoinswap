# Stands in for TronGrid, so a scan can be driven without a node. Blocks that
# were not set up come back empty.
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
              "data" => "a9059cbb#{"0" * 24}#{address_hex(to)}#{"%064x" % value}"
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

  private

  # The twenty address bytes of a base58 T-address, as hex without the version
  # byte and checksum that base58check wraps around them.
  def address_hex(address)
    ::Bitcoin::Base58.decode(address)[2, 40]
  end
end
