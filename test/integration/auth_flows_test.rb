require 'test_helper'

class AuthFlowsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  test "can login with valid authorization code" do
    get "/?auth_code=MyString1&email=alice%40example.com"
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_select "body", /Logged in!/

    delete "/logout"
    assert_response :redirect
    follow_redirect!
    assert_response :success

  end


  test "cannot login with valid authorization code" do
    delete "/logout"
    assert_response :redirect
    follow_redirect!
    assert_response :success
    get "/?auth_code=MyString0&email=alice%40example.com"
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_select "body", /Authorization code not found/

  end
end
