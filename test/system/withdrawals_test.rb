require "application_system_test_case"

class WithdrawalsTest < ApplicationSystemTestCase
  setup do
    @withdrawal = withdrawals(:one)
  end

  test "visiting the index" do
    visit withdrawals_url
    assert_selector "h1", text: "Withdrawals"
  end

  test "creating a Withdrawal" do
    visit withdrawals_url
    click_on "New Withdrawal"

    fill_in "Amount", with: @withdrawal.amount
    fill_in "Error", with: @withdrawal.error
    fill_in "Error At", with: @withdrawal.error_at
    fill_in "Receiver Address", with: @withdrawal.receiver_address
    fill_in "Signed Transaction", with: @withdrawal.signed_transaction
    fill_in "Status", with: @withdrawal.status
    fill_in "Submitted At", with: @withdrawal.submitted_at
    fill_in "Symbol", with: @withdrawal.symbol
    fill_in "Transaction", with: @withdrawal.transaction_id
    fill_in "Tries", with: @withdrawal.tries
    fill_in "User", with: @withdrawal.user_id
    click_on "Create Withdrawal"

    assert_text "Withdrawal was successfully created"
    click_on "Back"
  end

  test "updating a Withdrawal" do
    visit withdrawals_url
    click_on "Edit", match: :first

    fill_in "Amount", with: @withdrawal.amount
    fill_in "Error", with: @withdrawal.error
    fill_in "Error At", with: @withdrawal.error_at
    fill_in "Receiver Address", with: @withdrawal.receiver_address
    fill_in "Signed Transaction", with: @withdrawal.signed_transaction
    fill_in "Status", with: @withdrawal.status
    fill_in "Submitted At", with: @withdrawal.submitted_at
    fill_in "Symbol", with: @withdrawal.symbol
    fill_in "Transaction", with: @withdrawal.transaction_id
    fill_in "Tries", with: @withdrawal.tries
    fill_in "User", with: @withdrawal.user_id
    click_on "Update Withdrawal"

    assert_text "Withdrawal was successfully updated"
    click_on "Back"
  end

  test "destroying a Withdrawal" do
    visit withdrawals_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Withdrawal was successfully destroyed"
  end
end
