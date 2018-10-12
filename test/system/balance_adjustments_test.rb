require "application_system_test_case"

class BalanceAdjustmentsTest < ApplicationSystemTestCase
  setup do
    @balance_adjustment = balance_adjustments(:one)
  end

  test "visiting the index" do
    visit balance_adjustments_url
    assert_selector "h1", text: "Balance Adjustments"
  end

  test "creating a Balance adjustment" do
    visit balance_adjustments_url
    click_on "New Balance Adjustment"

    fill_in "Amount", with: @balance_adjustment.amount
    fill_in "Change", with: @balance_adjustment.change_id
    fill_in "Change Type", with: @balance_adjustment.change_type
    fill_in "Asset", with: @balance_adjustment.asset_id
    fill_in "Memo", with: @balance_adjustment.memo
    fill_in "User", with: @balance_adjustment.user_id
    click_on "Create Balance adjustment"

    assert_text "Balance adjustment was successfully created"
    click_on "Back"
  end

  test "updating a Balance adjustment" do
    visit balance_adjustments_url
    click_on "Edit", match: :first

    fill_in "Amount", with: @balance_adjustment.amount
    fill_in "Change", with: @balance_adjustment.change_id
    fill_in "Change Type", with: @balance_adjustment.change_type
    fill_in "Asset", with: @balance_adjustment.asset_id
    fill_in "Memo", with: @balance_adjustment.memo
    fill_in "User", with: @balance_adjustment.user_id
    click_on "Update Balance adjustment"

    assert_text "Balance adjustment was successfully updated"
    click_on "Back"
  end

  test "destroying a Balance adjustment" do
    visit balance_adjustments_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Balance adjustment was successfully destroyed"
  end
end
