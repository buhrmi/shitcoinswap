require 'test_helper'

class AuthorizationCodesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @authorization_code = authorization_codes(:one)
  end

  test "should get index" do
    get authorization_codes_url
    assert_response :success
  end

  test "should get new" do
    get new_authorization_code_url
    assert_response :success
  end

  test "should create authorization_code" do
    assert_difference('AuthorizationCode.count') do
      post authorization_codes_url, params: { authorization_code: { token: @authorization_code.token, used_at: @authorization_code.used_at, user_id: @authorization_code.user_id } }
    end

    assert_redirected_to authorization_code_url(AuthorizationCode.last)
  end

  test "should show authorization_code" do
    get authorization_code_url(@authorization_code)
    assert_response :success
  end

  test "should get edit" do
    get edit_authorization_code_url(@authorization_code)
    assert_response :success
  end

  test "should update authorization_code" do
    patch authorization_code_url(@authorization_code), params: { authorization_code: { token: @authorization_code.token, used_at: @authorization_code.used_at, user_id: @authorization_code.user_id } }
    assert_redirected_to authorization_code_url(@authorization_code)
  end

  test "should destroy authorization_code" do
    assert_difference('AuthorizationCode.count', -1) do
      delete authorization_code_url(@authorization_code)
    end

    assert_redirected_to authorization_codes_url
  end
end
