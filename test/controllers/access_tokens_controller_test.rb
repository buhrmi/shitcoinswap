require 'test_helper'

class AccessTokensControllerTest < ActionDispatch::IntegrationTest
  test "can not create access_token with wrong password" do
    assert_no_changes('AccessToken.count') do
      post login_url, params: { login: { email: 'alice@example.com', password: 'notalice' } }
    end
  end

  test "can create access_token with wrong password" do
    assert_changes('AccessToken.count') do
      post login_url, params: { login: { email: 'alice@example.com', password: 'alice' } }
    end
  end
end
