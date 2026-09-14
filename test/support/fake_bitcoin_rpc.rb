# Stands in for Bitcoin::RPC::BitcoinCoreClient, so a scan can be driven without
# a node. Heights that were not set up come back as empty blocks.
class FakeBitcoinRpc
  attr_accessor :height

  def initialize(height:)
    @height = height
    @blocks = {}
  end

  # Adds a block paying the given address (or addresses).
  def with_block(height, paying:, value: 0.5)
    @blocks["block-#{height}"] = {
      "tx" => [ {
        "txid" => "tx-#{height}",
        "vout" => Array(paying).map do |address|
          { "value" => value, "scriptPubKey" => { "address" => address } }
        end
      } ]
    }
    self
  end

  def getblockcount
    height
  end

  def getblockhash(height)
    "block-#{height}"
  end

  def getblock(hash, _verbosity)
    @blocks[hash] || { "tx" => [] }
  end
end
