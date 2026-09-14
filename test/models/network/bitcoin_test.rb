require "test_helper"
require "socket"

class Network::BitcoinTest < ActiveSupport::TestCase
  setup do
    @network = Network::Bitcoin.find(networks(:bitcoin).id)
    @asset = assets(:bitcoin)
    @wallet = Wallet.create!(user: users(:one), asset: @asset)
  end

  test "uses the public node for the chain in use" do
    assert_equal "https://bitcoin-rpc.publicnode.com", Network::Bitcoin.rpc_url(:mainnet)
    assert_equal "https://bitcoin-testnet-rpc.publicnode.com", Network::Bitcoin.rpc_url(:testnet)
    assert_equal "https://bitcoin-signet-rpc.publicnode.com", Network::Bitcoin.rpc_url(:signet)
  end

  test "follows the configured chain by default" do
    assert_equal Network::Bitcoin::RPC_URLS.fetch(::Bitcoin.chain_params.network), Network::Bitcoin.rpc_url
    assert_includes Network::Bitcoin::RPC_URLS.values, Network::Bitcoin.rpc_url
  end

  test "lets BTC_RPC_URL point at another node" do
    ENV["BTC_RPC_URL"] = "http://user:password@127.0.0.1:8332"

    assert_equal "http://user:password@127.0.0.1:8332", Network::Bitcoin.rpc_url
  ensure
    ENV.delete("BTC_RPC_URL")
  end

  test "complains about a chain it has no public node for" do
    assert_raises(KeyError) { Network::Bitcoin.rpc_url(:regtest) }
  end

  test "records an output paying one of our wallets" do
    # At the tip, so it has a single confirmation and is not spendable yet.
    @network.rpc = FakeBitcoinRpc.new(height: 103).with_block(103, paying: @wallet.address, value: 0.5)

    report = @network.scan_deposits(depth: 1)

    assert_equal({ from: 103, to: 103, created: 1, refreshed: 0, credited: 0 }, report)

    deposit = @network.deposits.find_by(tx: "tx-103", tx_idx: 0)
    assert_equal @wallet, deposit.wallet
    assert_equal @asset.id, deposit.asset_id
    assert_equal @wallet.user_id, deposit.user_id
    assert_equal BigDecimal("0.5"), deposit.amount
    assert_equal 103, deposit.block_height
    assert_equal 1, deposit.confirmations
  end

  test "remembers the height it scanned up to" do
    @network.rpc = FakeBitcoinRpc.new(height: 105).with_block(103, paying: @wallet.address)

    @network.scan_deposits(depth: 3)

    assert_equal 105, @network.reload.last_scanned_height
  end

  test "continues from the last scanned height instead of starting over" do
    client = FakeBitcoinRpc.new(height: 105).with_block(103, paying: @wallet.address)
    @network.rpc = client
    @network.scan_deposits(depth: 3)

    client.height = 106
    report = @network.scan_deposits

    assert_equal 106, report[:from]
    assert_equal 0, report[:created]
    assert_equal 1, @network.deposits.count
  end

  test "recounts the confirmations of deposits that are still counting up" do
    # One confirmation, so it is still short of the threshold.
    client = FakeBitcoinRpc.new(height: 104).with_block(104, paying: @wallet.address)
    @network.rpc = client
    @network.scan_deposits(depth: 1)

    client.height = 104 - 1 + Deposit::CONFIRMATIONS_NEEDED
    report = @network.scan_deposits

    assert_equal 1, report[:refreshed]

    deposit = @network.deposits.find_by(tx: "tx-104")
    assert_equal Deposit::CONFIRMATIONS_NEEDED, deposit.confirmations
    assert deposit.confirmed?
  end

  test "records deposits for every asset on the network in one pass" do
    # The whole point of keeping the cursor on the network: one walk of the
    # chain serves all the tokens on it.
    token = Asset::Bitcoin.create!(name: "Token", network: @network)
    other_wallet = Wallet.create!(user: users(:two), asset: token)

    @network.rpc = FakeBitcoinRpc.new(height: 105)
      .with_block(103, paying: [ @wallet.address, other_wallet.address ])

    report = @network.scan_deposits(depth: 3)

    assert_equal 2, report[:created]
    assert_equal [ @wallet.id, other_wallet.id ], @network.deposits.order(:asset_id).pluck(:wallet_id)
    assert_equal [ @asset.id, token.id ], @network.deposits.order(:asset_id).pluck(:asset_id)
  end

  test "credits the balance once the deposit is deep enough" do
    client = FakeBitcoinRpc.new(height: 104).with_block(104, paying: @wallet.address, value: 0.5)
    @network.rpc = client

    # One confirmation is not enough to spend yet.
    report = @network.scan_deposits(depth: 1)

    assert_equal 0, report[:credited]
    assert_nil @wallet.user.balances.find_by(asset: @asset)

    client.height = 104 - 1 + Deposit::CONFIRMATIONS_NEEDED
    report = @network.scan_deposits

    assert_equal 1, report[:credited]

    balance = @wallet.user.balances.find_by(asset: @asset)
    assert_equal BigDecimal("0.5"), balance.total
    assert_equal BigDecimal("0.5"), balance.available
    assert_not_nil @network.deposits.find_by(tx: "tx-104").credited_at

    # Crediting happens once, however often the chain is scanned.
    client.height += 1
    assert_equal 0, @network.scan_deposits[:credited]
    assert_equal BigDecimal("0.5"), balance.reload.total
  end

  test "ignores outputs that do not pay one of our wallets" do
    @network.rpc = FakeBitcoinRpc.new(height: 105).with_block(103, paying: "tb1qsomeoneelse")

    report = @network.scan_deposits(depth: 3)

    assert_equal 0, report[:created]
    assert_equal 0, @network.deposits.count
  end

  test "does not scan backwards when the tip is below the scanned height" do
    client = FakeBitcoinRpc.new(height: 105).with_block(103, paying: @wallet.address)
    @network.rpc = client
    @network.scan_deposits(depth: 3)

    client.height = 100
    @network.scan_deposits

    assert_equal 105, @network.reload.last_scanned_height
  end

  test "rpc sends a json-rpc call and returns the result" do
    with_server(JSON.generate(result: 966_939, error: nil, id: "getblockcount")) do |url|
      assert_equal 966_939, Network::Bitcoin::Rpc.new(url).getblockcount
    end
  end

  test "rpc sends the method and params of the call" do
    with_server(JSON.generate(result: "hash", error: nil, id: "getblockhash")) do |url|
      assert_equal "hash", Network::Bitcoin::Rpc.new(url).getblockhash(812_345)
    end

    assert_includes received_request, '"method":"getblockhash"'
    assert_includes received_request, '"params":[812345]'
  end

  test "rpc raises with the error the node reported" do
    with_server(JSON.generate(result: nil, error: { code: -8, message: "Block height out of range" })) do |url|
      error = assert_raises(RuntimeError) { Network::Bitcoin::Rpc.new(url).getblockhash(99_999_999) }
      assert_includes error.message, "Block height out of range"
    end
  end

  test "rpc raises when the node answers with an http error" do
    with_server("nope", status: "503 Service Unavailable") do |url|
      error = assert_raises(RuntimeError) { Network::Bitcoin::Rpc.new(url).getblockcount }
      assert_includes error.message, "HTTP 503"
    end
  end

  private

  attr_reader :received_request

  # Serves one canned response from a local socket, so the client's request and
  # response handling is exercised without a node (or a network).
  def with_server(body, status: "200 OK")
    server = TCPServer.new("127.0.0.1", 0)

    thread = Thread.new do
      socket = server.accept
      @received_request = read_request(socket)
      socket.write(
        "HTTP/1.1 #{status}\r\ncontent-type: application/json\r\n" \
        "content-length: #{body.bytesize}\r\nconnection: close\r\n\r\n#{body}"
      )
      socket.close
    end

    yield "http://127.0.0.1:#{server.addr[1]}"
  ensure
    thread&.join(5)
    server&.close
  end

  def read_request(socket)
    request = +""
    request << socket.readpartial(4096) until request.include?("jsonrpc") || request.bytesize > 8192
    request
  end
end
