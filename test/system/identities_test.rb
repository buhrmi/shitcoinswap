require "application_system_test_case"

class IdentitiesTest < ApplicationSystemTestCase
  self.fixture_table_names = [ :users ]

  test "logged in user can connect a discord account" do
    identity = Identity.from_omniauth!(discord_auth_hash, users(:one))

    visit root_path
    log_in(users(:one))
    visit identities_path

    assert_text "discord: Discord Name"
    assert_equal users(:one), identity.user
    assert_no_button "Connect Discord"
  end

  test "logged in user cannot connect a discord account owned by another user" do
    identity = Identity.create!(
      user: users(:two),
      provider: "discord",
      provider_id: "discord-123",
      info: { "name" => "Discord Name" }
    )
    connected_identity = Identity.from_omniauth!(discord_auth_hash, users(:one))

    visit root_path
    log_in(users(:one))
    visit identities_path

    assert_text "No connections yet."
    assert_button "Connect Discord"
    assert_equal identity, connected_identity
    assert_equal users(:two), identity.reload.user
  end

  private

  def log_in(user)
    click_on "Log in"

    find("#email").fill_in with: user.email
    find("input[name=password]").fill_in with: "password123"
    click_on "Sign in"

    assert_text "Logged in as #{user.name}"
  end

  def discord_auth_hash
    OmniAuth::AuthHash.new(
      provider: "discord",
      uid: "discord-123",
      info: {
        name: "Discord Name",
        email: "discord@example.com"
      }
    )
  end
end