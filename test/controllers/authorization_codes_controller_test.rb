require 'test_helper'

class AuthorizationCodesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @authorization_code = authorization_codes(:one)
  end

  test "should get new" do
    get new_authorization_code_url
    assert_response :success
  end

  # test "should get edit" do
  #   get edit_authorization_code_url(@authorization_code)
  #   assert_response :success
  # end

end
