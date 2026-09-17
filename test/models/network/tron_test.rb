require "test_helper"

class Network::TronTest < ActiveSupport::TestCase
  setup do
    @network = Network::Tron.find(networks(:tron).id)
    @asset = assets(:usdt)
    @wallet = Wallet.create!(user: users(:one), asset: @asset)
  end

  test "hashes with keccak, not with the sha3 it resembles" do
    # The one primitive taken from a gem: this is Keccak-256 of the empty string,
    # which is what account addresses are built on.
    assert_equal "c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470",
      Digest::Keccak.hexdigest("", 256)
  end

  test "derives the wallet's address from the network's key" do
    assert_equal @network.derive_address(users(:one).id, 1), @wallet.address
    assert_match(/\AT[1-9A-HJ-NP-Za-km-z]{33}\z/, @wallet.address)
  end

  test "writes the same address ethereum writes in hex" do
    # One key, the same twenty bytes, on both chains: only the encoding differs.
    ethereum = Network::Ethereum.new(name: "Ethereum", config: @network.config)

    assert_equal "0x#{::Bitcoin::Base58.decode(@wallet.address)[2, 40]}",
      ethereum.derive_address(users(:one).id, 1)
  end

  test "records a transfer that pays one of our wallets" do
    @network.rpc = FakeTronRpc.new(height: 103)
      .with_transfer(103, to: @wallet.address, contract: @asset.contract, value: 12_750_000)

    report = @network.scan_deposits(depth: 1)

    assert_equal({ from: 103, to: 103, created: 1, refreshed: 0, credited: 0 }, report)

    deposit = @network.deposits.find_by(wallet: @wallet)
    assert_equal @asset.id, deposit.asset_id
    assert_equal users(:one).id, deposit.user_id
    assert_equal BigDecimal("12.75"), deposit.amount
    assert_equal 103, deposit.block_height
    assert_equal 1, deposit.confirmations
  end

  test "tells the tokens on the chain apart by their contract" do
    # Every token is paid to the same address, so the contract is what says which
    # asset a transfer belongs to.
    other = Asset::Evm.create!(name: "Another token", network: @network, config: { contract: "TOtherToken", decimals: 0 })
    other_wallet = Wallet.create!(user: users(:one), asset: other)

    assert_equal @wallet.address, other_wallet.address

    @network.rpc = FakeTronRpc.new(height: 103)
      .with_transfer(103, to: @wallet.address, contract: other.contract, value: 5)

    @network.scan_deposits(depth: 1)

    assert_equal [ other.id ], @network.deposits.pluck(:asset_id)
    assert_equal BigDecimal("5"), @network.deposits.first.amount
  end

  test "ignores transfers of a contract we do not track" do
    @network.rpc = FakeTronRpc.new(height: 103)
      .with_transfer(103, to: @wallet.address, contract: "TSomeOtherContract", value: 1)

    assert_equal 0, @network.scan_deposits(depth: 1)[:created]
  end

  test "ignores transfers that did not go through" do
    @network.rpc = FakeTronRpc.new(height: 103)
      .with_transfer(103, to: @wallet.address, contract: @asset.contract, value: 1, status: "REVERT")

    assert_equal 0, @network.scan_deposits(depth: 1)[:created]
  end

  test "ignores transfers that pay somebody else" do
    @network.rpc = FakeTronRpc.new(height: 105)
      .with_transfer(103, to: @network.derive_address(42, 7), contract: @asset.contract, value: 1)

    assert_equal 0, @network.scan_deposits(depth: 3)[:created]
    assert_equal 0, @network.deposits.count
  end

  test "remembers the height it scanned up to" do
    @network.rpc = FakeTronRpc.new(height: 105)
      .with_transfer(103, to: @wallet.address, contract: @asset.contract, value: 1)

    @network.scan_deposits(depth: 3)

    assert_equal 105, @network.reload.last_scanned_height
  end

  test "continues from the last scanned height instead of starting over" do
    client = FakeTronRpc.new(height: 105)
      .with_transfer(103, to: @wallet.address, contract: @asset.contract, value: 1)
    @network.rpc = client
    @network.scan_deposits(depth: 3)

    client.height = 106
    report = @network.scan_deposits

    assert_equal 106, report[:from]
    assert_equal 0, report[:created]
    assert_equal 1, @network.deposits.count
  end

  test "credits the balance once the transfer is confirmed" do
    client = FakeTronRpc.new(height: 104)
      .with_transfer(104, to: @wallet.address, contract: @asset.contract, value: 12_750_000)
    @network.rpc = client

    # One confirmation is not enough to spend yet.
    assert_equal 0, @network.scan_deposits(depth: 1)[:credited]
    assert_nil users(:one).balances.find_by(asset: @asset)

    client.height = 104 - 1 + Deposit::CONFIRMATIONS_NEEDED
    assert_equal 1, @network.scan_deposits[:credited]

    balance = users(:one).balances.find_by(asset: @asset)
    assert_equal BigDecimal("12.75"), balance.total
    assert_equal BigDecimal("12.75"), balance.available

    # Crediting happens once, however often the chain is scanned.
    client.height += 1
    assert_equal 0, @network.scan_deposits[:credited]
    assert_equal BigDecimal("12.75"), balance.reload.total
  end
end
