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
    assert_select "body", "Admin Menu: Balance Adjustments | Platforms | Withdrawals | Assets
      
    NewArt Technology
    OTC
      
        Logged in as alice@example.com | My Balances | Account History | Log Out
      
    
    
      Logged in!


    Welcome to NewArt Technology"

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
    assert_select "body", "NewArt Technology
    OTC
      
      Log In
    
    

      Authorization code not found. Please use the latest link sent to your email.

    New Authorization Code

  
    Email
    
  
  
    
  

Back"

  end
end
