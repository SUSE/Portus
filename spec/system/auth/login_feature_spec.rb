# frozen_string_literal: true

require "rails_helper"

describe "Login feature" do
  let!(:registry) { create(:registry) }
  let!(:user) { create(:user) }

  before do
    visit new_user_session_path
  end

  it "does not show any flash when accessing for the first time" do
    visit root_path
    expect(page).not_to have_content("You need to sign in or sign up before continuing.")
  end

  it "does show a warning for the admin creation in LDAP support" do
    User.delete_all
    APP_CONFIG["first_user_admin"] = { "enabled" => false }
    APP_CONFIG["ldap"]["enabled"] = true
    visit new_user_session_path

    expect(page).not_to have_content("The first user to be created will have admin permissions !")
    expect(page).not_to have_content("Create a new account")
    expect(page).not_to have_content("I forgot my password")

    APP_CONFIG["first_user_admin"] = { "enabled" => true }
    visit new_user_session_path

    expect(page).to have_content("The first user to be created will have admin permissions !")

    create(:admin)

    visit new_user_session_path
    expect(page).not_to have_content("The first user to be created will have admin permissions !")
  end

  it "Skips validation of minimum password length when authenticating via LDAP" do
    APP_CONFIG["ldap"]["enabled"] = true

    # Skipping validation for LDAP users is configured when the user model is first interpreted
    # Use a clean room to guard against side effects
    module CleanRoom
      # rubocop:disable Security/Eval
      eval File.read(Rails.root.join("app", "models", "user.rb"))
      # rubocop:enable Security/Eval
    end

    ldap_user = CleanRoom::User.first
    ldap_user.password = "short"
    expect(ldap_user.save).to be(true)

    fill_in "user_username", with: ldap_user.username
    fill_in "user_password", with: ldap_user.password
    click_button "Login"

    expect(page).to have_content("Recent activities")
    expect(page).to have_content("Repositories")
  end

  it "Existing user is able using his login and password to login into Portus" do
    expect(page).not_to have_content("Invalid username or password")

    # We don't use Capybara's `login_as` method on purpose, because we are
    # testing the UI for logging in.
    fill_in "user_username", with: user.username
    fill_in "user_password", with: user.password
    find("#login-btn").click

    expect(page).to have_content("Recent activities")
    expect(page).to have_content("Repositories")
    expect(page).not_to have_content("Signed in")
  end

  it "Wrong password results in an error message" do
    fill_in "user_username", with: "foo"
    fill_in "user_password", with: "bar"
    find("#login-btn").click

    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_content("Invalid Username or password")
  end

  it "When guest tries to access dashboard - he is redirected to the login page" do
    visit root_path
    expect(page).to have_content("Login")
    expect(page).to have_current_path(root_path)
  end

  it "Successful login when trying to access a page redirects back the guest", js: true do
    visit namespaces_path
    expect(page).to have_content("You need to sign in or sign up before continuing.")
    fill_in "user_username", with: user.username
    fill_in "user_password", with: user.password
    find("button.classbutton").click
    expect(page).to have_current_path(namespaces_path)
    expect(page).to have_content("Namespaces you have access to")
  end

  it "A disabled user cannot login" do
    user.update(enabled: false)
    fill_in "user_username", with: user.username
    fill_in "user_password", with: user.password
    find("#login-btn").click

    expect(page).to have_content(user.inactive_message)
    expect(page).to have_content("Login")
    expect(page).to have_current_path(new_user_session_path)
  end

  it "Login form is enabled when local_login is enabled" do
    APP_CONFIG["oauth"]["local_login"] = { "enabled" => true }
    APP_CONFIG["ldap"]["enabled"] = false

    visit root_path
    expect(page).to have_current_path(root_path)
    expect(page).to have_content("Login")
    expect(page).to have_content("I forgot my password")
  end

  it "Login form is enabled when ldap is enabled" do
    APP_CONFIG["oauth"]["local_login"] = { "enabled" => false }
    APP_CONFIG["ldap"]["enabled"] = true

    visit root_path
    expect(page).to have_current_path(root_path)
    expect(page).to have_content("Login")
    expect(page).not_to have_content("I forgot my password")
  end

  it "Login form is disabled when both local_login and ldap are disabled" do
    APP_CONFIG["oauth"]["local_login"] = { "enabled" => false }
    APP_CONFIG["ldap"]["enabled"] = false

    visit root_path
    expect(page).to have_current_path(root_path)
    expect(page).not_to have_content("Login")
    expect(page).not_to have_content("I forgot my password")
  end

  it "Sign up is disabled" do
    APP_CONFIG["signup"] = { "enabled" => true }

    visit root_path
    expect(page).to have_current_path(root_path)
    expect(page).to have_content("Create a new account")

    APP_CONFIG["signup"] = { "enabled" => false }

    visit root_path
    expect(page).to have_current_path(root_path)
    expect(page).to have_content("I forgot my password")
    expect(page).not_to have_content("Create a new account")
  end

  describe "User is lockable" do
    before do
      @attempts  = Devise.maximum_attempts
      @unlock_in = Devise.unlock_in
    end

    after do
      Devise.maximum_attempts = @attempts
      Devise.unlock_in        = @unlock_in
    end

    it "locks the user when too many attempts have been made" do
      # Let's be fast and lock on the first attempt.
      Devise.maximum_attempts = 1

      # Lock the account.
      fill_in "user_username", with: user.username
      fill_in "user_password", with: "#{user.password}1"
      find("#new_user button").click

      expect(page).to have_content("Your account is locked.")
      user.reload
      expect(user).to be_access_locked

      # The account is locked, regardless that we provide the proper password
      # now.
      fill_in "user_username", with: user.username
      fill_in "user_password", with: user.password
      find("#new_user button").click

      expect(page).to have_content("Your account is locked.")
      user.reload
      expect(user).to be_access_locked

      # Unlock the account, the locking time has expired.
      Devise.unlock_in = 1.second
      sleep 1
      fill_in "user_username", with: user.username
      fill_in "user_password", with: user.password
      find("#new_user button").click
    end
  end

  describe "LDAP login" do
    it "welcomes the user if it got created" do
      APP_CONFIG["ldap"]["enabled"] = true
      Rails.application.env_config[:first_login] = true

      visit new_user_session_path
      fill_in "user_username", with: user.username
      fill_in "user_password", with: user.password
      find("#new_user button").click

      expect(page).to have_current_path(authenticated_root_path)
      expect(page).to have_content("Welcome!")
    end
  end
end
