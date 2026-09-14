require "application_system_test_case"

# The deposit page and the balances are read from the user's local Dexie copy,
# which the server keeps up to date over ActionCable. So this drives a browser
# instead of asserting on a response body.
class WalletsTest < ApplicationSystemTestCase
  test "depositing to the address on the deposit page shows up in the balance" do
    asset = assets(:bitcoin)
    user = users(:one)
    user.balances.create!(asset: asset)

    visit root_path
    log_in(user)

    assert_text "Bitcoin: 0.0"

    # Marker to prove below that the page is never reloaded.
    page.execute_script("window.walletsTestLoaded = true")

    click_on "Deposit"
    assert_text "Waiting..."

    # The address is shown as a QR code, with the copy button below it.
    assert_selector ".qr"
    assert_button "Copy address"

    # Pay the address the deposit page is showing, the way the chain scan would
    # pick it up.
    address = find("code.address").text
    network = Network::Bitcoin.find(networks(:bitcoin).id)
    network.rpc = FakeBitcoinRpc.new(height: 105 + Deposit::CONFIRMATIONS_NEEDED - 1)
      .with_block(105, paying: address, value: 0.5)
    report = network.scan_deposits(depth: Deposit::CONFIRMATIONS_NEEDED)

    assert_equal 1, report[:credited]
    assert_equal 1, user.deposits.count

    # The deposit appears in the list, and the balance it was credited to is
    # there when we go back.
    assert_text "Got deposit: 0.5"

    click_on "Back"

    assert_text "Bitcoin: 0.5"
    assert page.evaluate_script("window.walletsTestLoaded === true")
  end

  private

  def log_in(user)
    click_on "Log in"

    find("#email").fill_in with: user.email
    find("input[name=password]").fill_in with: "password123"
    click_on "Sign in"

    assert_text "Logged in as #{user.name}"
  end
end
