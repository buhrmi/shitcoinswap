require "test_helper"

class AssetTest < ActiveSupport::TestCase
  test "an asset that is on no network has no address to give a wallet" do
    # Not every asset is a token on a chain - the seeds have one that is not - and
    # a wallet on one of those has nowhere to receive anything.
    asset = Asset.create!(name: "Not on a chain")

    assert_raises(RuntimeError) { Wallet.create!(user: users(:one), asset: asset) }
  end
end
