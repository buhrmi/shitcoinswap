require "test_helper"

class AssetsControllerTest < ActionDispatch::IntegrationTest
  test "shows an asset by its id" do
    get asset_path(assets(:usdt))

    assert_response :success
    assert_includes response.body, assets(:usdt).name
  end

  test "shows a token by the network and contract it lives in" do
    get asset_by_contract_path(network: networks(:tron).name, contract: assets(:usdt).contract_address)

    assert_response :success
    assert_includes response.body, assets(:usdt).name
  end

  test "does not answer for a contract that is not on the network" do
    get asset_by_contract_path(network: networks(:bitcoin).name, contract: assets(:usdt).contract_address)

    assert_response :not_found
  end
end
