require "application_system_test_case"

class AuthorizationCodesTest < ApplicationSystemTestCase
  setup do
    @authorization_code = authorization_codes(:one)
  end

  test "visiting the index" do
    visit authorization_codes_url
    assert_selector "h1", text: "Authorization Codes"
  end

  test "creating a Authorization code" do
    visit authorization_codes_url
    click_on "New Authorization Code"

    fill_in "Token", with: @authorization_code.token
    fill_in "Used At", with: @authorization_code.used_at
    fill_in "User", with: @authorization_code.user_id
    click_on "Create Authorization code"

    assert_text "Authorization code was successfully created"
    click_on "Back"
  end

  test "updating a Authorization code" do
    visit authorization_codes_url
    click_on "Edit", match: :first

    fill_in "Token", with: @authorization_code.token
    fill_in "Used At", with: @authorization_code.used_at
    fill_in "User", with: @authorization_code.user_id
    click_on "Update Authorization code"

    assert_text "Authorization code was successfully updated"
    click_on "Back"
  end

  test "destroying a Authorization code" do
    visit authorization_codes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Authorization code was successfully destroyed"
  end
end
