require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "should get login_email" do
    get static_pages_login_email_url
    assert_response :success
  end

end
