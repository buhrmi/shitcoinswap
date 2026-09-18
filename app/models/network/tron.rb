class Network::Tron < Network::Evm
  # Tron makes a block every three seconds, so a first scan looks much deeper than on
  # Bitcoin to cover a similar stretch of time: 200 blocks is about ten minutes, and 200
  # calls on a shared public node.
  INITIAL_DEPTH = 200

  # A Tron address is the 20 bytes Ethereum would write in hex, with Tron's own
  # version byte in front and a base58check checksum around them.
  ADDRESS_PREFIX = "\x41".b

  def tip_height
    rpc.getnowblock
  end

  # Kept per instance so a scan reuses one client; assigning one is how tests stub it.
  attr_writer :rpc

  def rpc
    @rpc ||= Rpc.new(rpc_url)
  end

  private

  def encode_address(bytes)
    payload = (ADDRESS_PREFIX + bytes).unpack1("H*")
    ::Bitcoin::Base58.encode(payload + ::Bitcoin.calc_checksum(payload))
  end

  # A base58 address in the node's own hex form, version byte and all.
  def address_hex(address)
    ::Bitcoin::Base58.decode(address)[0, 42]
  end

  # Tron's constant call: the node runs a contract's function for us, which is
  # where a token's name, symbol and decimals come from.
  def call_contract(contract, signature)
    rpc.call_contract(address_hex(contract), signature)
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

  # The call a transaction makes to a token contract, or nil when it failed or is not one.
  def token_call_in(tx)
    return unless tx.dig("ret", 0, "contractRet") == "SUCCESS"

    call = tx.dig("raw_data", "contract").to_a.find { |contract| contract["type"] == "TriggerSmartContract" }
    call&.dig("parameter", "value")
  end

  def block_at(height)
    rpc.getblockbynum(height)
  end

  # Minimal client for the handful of calls a scan makes. A Tron node names the method in
  # the path and takes a plain JSON body, so unlike Bitcoin's node this is not JSON-RPC.
  # `visible: true` asks for base58 addresses.
  class Rpc
    OPEN_TIMEOUT = 5
    READ_TIMEOUT = 60

    # A constant call changes nothing, so nobody has to sign it: the null account stands
    # in, and the addresses on that call are hex rather than base58.
    NULL_ADDRESS = "41" + "00" * 20

    def initialize(url)
      @uri = URI.parse(url)
    end

    def getnowblock
      call("getnowblock").dig("block_header", "raw_data", "number")
    end

    def getblockbynum(num)
      call("getblockbynum", num: num)
    end

    def call_contract(contract_hex, signature)
      call(
        "triggerconstantcontract", visible: false, owner_address: NULL_ADDRESS,
        contract_address: contract_hex, function_selector: signature, parameter: ""
      ).dig("constant_result", 0)
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
