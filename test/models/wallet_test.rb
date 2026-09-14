require "test_helper"

class WalletTest < ActiveSupport::TestCase
  test "assigns an address to the wallet when it is generated" do
    wallet = Wallet.create!(user: users(:one), asset: assets(:bitcoin))

    assert wallet.address.present?
    assert_equal wallet.address, wallet.reload.address
  end
end
