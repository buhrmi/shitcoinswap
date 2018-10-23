require "application_system_test_case"

class AirdropsTest < ApplicationSystemTestCase
  setup do
    @airdrop = airdrops(:one)
  end

  test "visiting the index" do
    visit airdrops_url
    assert_selector "h1", text: "Airdrops"
  end

  test "creating a Airdrop" do
    visit airdrops_url
    click_on "New Airdrop"

    fill_in "Amounts", with: @airdrop.amounts
    fill_in "Asset", with: @airdrop.asset_id
    fill_in "Executed At", with: @airdrop.executed_at
    fill_in "Memo", with: @airdrop.memo
    fill_in "User", with: @airdrop.user_id
    click_on "Create Airdrop"

    assert_text "Airdrop was successfully created"
    click_on "Back"
  end

  test "updating a Airdrop" do
    visit airdrops_url
    click_on "Edit", match: :first

    fill_in "Amounts", with: @airdrop.amounts
    fill_in "Asset", with: @airdrop.asset_id
    fill_in "Executed At", with: @airdrop.executed_at
    fill_in "Memo", with: @airdrop.memo
    fill_in "User", with: @airdrop.user_id
    click_on "Update Airdrop"

    assert_text "Airdrop was successfully updated"
    click_on "Back"
  end

  test "destroying a Airdrop" do
    visit airdrops_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Airdrop was successfully destroyed"
  end
end
