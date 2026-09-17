require "test_helper"

class Asset::EvmTest < ActiveSupport::TestCase
  setup do
    @network = Network::Tron.find(networks(:tron).id)
    @contract = assets(:usdt).contract_address
    # A second real Tron address, so a test can have a token of its own without
    # colliding with the fixture.
    @other_contract = @network.derive_address(999, 1)
  end

  test "a token that is only given its contract is filled in from the chain" do
    @network.rpc = FakeTronRpc.new(height: 1)
      .with_token_metadata(@other_contract, name: "Test Token", symbol: "TEST", decimals: 8)

    asset = Asset::Evm.find_or_initialize_by(contract_address: @other_contract, network: @network)
    asset.save!

    # The contract is all the row was given, so its name and ticker come from there.
    assert_equal @other_contract, asset.contract_address
    assert_equal "Test Token", asset.name
    assert_equal "TEST", asset.symbol
    assert_equal 8, asset.decimals
    assert_equal BigDecimal("12.5"), asset.amount_from(1_250_000_000)
  end

  test "a token has to say which contract it lives in" do
    asset = Asset::Evm.new(name: "Nowhere", network: @network)

    assert_not asset.valid?
    assert_includes asset.errors[:contract_address], "can't be blank"
  end

  test "leaves a token that is already described alone" do
    # The double raises on any call, so reaching the chain would fail this test.
    @network.rpc = FakeTronRpc.new(height: 1)

    asset = Asset::Evm.create!(
      name: "USDT (Tron)", symbol: "USDT", network: @network,
      contract_address: @contract, decimals: 6
    )

    assert_equal "USDT (Tron)", asset.name
    assert_equal "USDT", asset.symbol
    assert_equal 6, asset.decimals
  end

  test "complains when the contract does not answer" do
    @network.rpc = FakeTronRpc.new(height: 1).with_token_metadata(@contract)

    assert_raises(RuntimeError) do
      Asset::Evm.create!(name: "Not a token", network: @network, contract_address: @contract)
    end
  end

  test "a token that does not say how many decimals it has cannot be counted in" do
    asset = Asset::Evm.new(name: "Half a token", network: @network, contract_address: @contract)

    assert_raises(RuntimeError) { asset.decimals }
  end
end
