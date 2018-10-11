require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "can not create session with wrong password" do
    assert_no_changes('Session.count') do
      post login_url, params: { login: { email: 'alice@example.com', password: 'notalice' } }
    end
  end

  test "can create session with wrong password" do
    assert_changes('Session.count') do
      post login_url, params: { login: { email: 'alice@example.com', password: 'alice' } }
    end
  end
end
