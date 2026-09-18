require "test_helper"

class AssetTest < ActiveSupport::TestCase
  test "an asset that is on no network has no address to give a wallet" do
    asset = Asset.create!(name: "Not on a chain")

    assert_raises(RuntimeError) { Wallet.create!(user: users(:one), asset: asset) }
  end

  test "carries what a link to a token needs" do
    json = assets(:usdt).as_json(Asset::JSON_OPTIONS)

    assert_equal assets(:usdt).contract_address, json["contract_address"]
    assert_equal networks(:tron).id, json["network_id"]
  end
end
