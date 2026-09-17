class Network::Tron < Network::Evm
  # Tron makes a block every three seconds, so a first scan has to look much
  # deeper than on Bitcoin to cover a similar stretch of time. Two hundred blocks
  # is about ten minutes, and costs two hundred calls on a public node.
  INITIAL_DEPTH = 200

  # A Tron address is the 20 bytes Ethereum would write in hex, with Tron's own
  # version byte in front and a base58check checksum around them.
  ADDRESS_PREFIX = "\x41".b

  def tip_height
    rpc.getnowblock
  end

  # Kept per instance so one scan reuses a single client; assigning one is also
  # how tests stub the network.
  attr_writer :rpc

  def rpc
    @rpc ||= Rpc.new(rpc_url)
  end

  private

  def encode_address(bytes)
    payload = (ADDRESS_PREFIX + bytes).unpack1("H*")
    ::Bitcoin::Base58.encode(payload + ::Bitcoin.calc_checksum(payload))
  end

  # Tron hands a block over as its transactions, and a token transfer is a
  # successful call to the token's own contract.
  def transfers_in(block)
    block["transactions"].to_a.each_with_index.filter_map do |tx, index|
      call = token_call_in(tx)
      transfer = call && transfer_in(call["data"])
      next unless transfer

      {
        tx: tx["txID"], tx_idx: index, contract: call["contract_address"],
        to: encode_address(transfer[:to]), amount: transfer[:amount]
      }
    end
  end

  # The call a transaction makes to a token contract, or nil when it failed or is
  # not a contract call at all.
  def token_call_in(tx)
    return unless tx.dig("ret", 0, "contractRet") == "SUCCESS"

    call = tx.dig("raw_data", "contract").to_a.find { |contract| contract["type"] == "TriggerSmartContract" }
    call&.dig("parameter", "value")
  end

  def block_at(height)
    rpc.getblockbynum(height)
  end

  # Minimal client for the handful of TronGrid calls a scan makes. TronGrid names
  # the method in the path and takes a plain JSON body, so unlike Bitcoin's node
  # this is not JSON-RPC. `visible: true` asks for base58 addresses.
  class Rpc
    OPEN_TIMEOUT = 5
    READ_TIMEOUT = 60

    def initialize(url)
      @uri = URI.parse(url)
    end

    def getnowblock
      call("getnowblock").dig("block_header", "raw_data", "number")
    end

    def getblockbynum(num)
      call("getblockbynum", num: num)
    end

    private

    def call(method, **params)
      response = Net::HTTP.start(
        @uri.hostname, @uri.port,
        use_ssl: @uri.scheme == "https",
        open_timeout: OPEN_TIMEOUT,
        read_timeout: READ_TIMEOUT
      ) { |http| http.request(request_for(method, params)) }

      raise "#{method} failed: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end

    def request_for(method, params)
      request = Net::HTTP::Post.new(URI.join(@uri.to_s, "/wallet/#{method}"), "content-type" => "application/json")
      request.basic_auth(@uri.user, @uri.password) if @uri.user
      request.body = JSON.generate({ visible: true }.merge(params))
      request
    end
  end
end
