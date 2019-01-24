# frozen_string_literal: true

require "rails_helper"

describe "Admin - Users panel", type: :system, js: true do
  let!(:registry) { create(:registry) }
  let!(:admin) { create(:admin) }
  let!(:user) { create(:user) }

  before do
    login_as admin
    visit admin_users_path
  end

  describe "create users" do
    it "admin creates a user" do
      visit admin_users_path

      find(".toggle-link-new-user").click

      fill_in "Username",              with: "username"
      fill_in "Email",                 with: "email@email.com"
      fill_in "user[password]",        with: "password123"
      fill_in "Password confirmation", with: "password123"

      click_button "Save"

      expect(page).to have_current_path(admin_users_path)
      expect(page).to have_content("User 'username' was created successfully")
    end

    it "admin creates a bot" do
      visit admin_users_path

      find(".toggle-link-new-user").click

      fill_in "Username",              with: "username"
      fill_in "Email",                 with: "email@email.com"
      fill_in "user[password]",        with: "password123"
      fill_in "Password confirmation", with: "password123"
      check "Bot"

      click_button "Save"
      expect(page).to have_content("Bot 'username' was created successfully")
      expect(page).not_to have_content("undefined")

      # TODO: remove lines below. They are not supposed to be in a feature test
      user = User.find_by(username: "username")
      expect(user.bot).to be_truthy

      # A new application token has been associated to this bot, but the
      # activity belongs to the admin.
      at = ApplicationToken.first
      expect(at.user_id).to eq user.id
      expect(PublicActivity::Activity.first.owner_id).to eq admin.id
    end

    it "admin adds back a removed user" do
      expect(page).to have_css(".user_#{user.id}")

      find(".user_#{user.id} .delete-user-btn").click
      find(".user_#{user.id} .yes").click

      expect(page).to have_content("User '#{user.username}' was removed successfully")

      visit admin_users_path

      find(".toggle-link-new-user").click

      fill_in "Username",              with: user.username
      fill_in "Email",                 with: user.email
      fill_in "user[password]",        with: "password123"
      fill_in "Password confirmation", with: "password123"

      click_button "Save"

      expect(page).to have_current_path(admin_users_path)
      expect(page).to have_content("User '#{user.username}' was created successfully")
    end
  end

  describe "remove users" do
    it "allows the admin to remove other users" do
      expect(page).to have_css(".user_#{user.id}")
      expect(page).to have_content(user.username)

      find(".user_#{user.id} .delete-user-btn").click
      find(".user_#{user.id} .yes").click

      expect(page).to have_content("User '#{user.username}' was removed successfully")
    end

    it "allows the admin to remove other users from the show page" do
      visit edit_admin_user_path(user.id)

      toggle_user_deletion_modal
      click_button "I understand, delete user"

      expect(page).to have_current_path(admin_users_path)
      expect(page).to have_content("User '#{user.username}' was removed successfully")
    end
  end

  describe "disable users" do
    it "allows the admin to disable other users" do
      expect(page).to have_css(".user_#{user.id}")
      find(".user_#{user.id} .toggle-user-enabled-btn").click

      expect(page).to have_css(".user_#{user.id} .fa-toggle-off")
      expect(page).to have_content("User '#{user.username}' has been disabled")
    end

    it "allows the admin to enable back a user" do
      user.update(enabled: false)
      visit admin_users_path

      expect(page).to have_css(".user_#{user.id}")
      find(".user_#{user.id} .toggle-user-enabled-btn").click

      expect(page).to have_css(".user_#{user.id} .fa-toggle-on")
      expect(page).to have_content("User '#{user.username}' has been enabled")
    end

    it "logs out admin if it disables itself" do
      admin2 = create(:admin)
      logout
      login_as admin2

      visit admin_users_path

      find(".user_#{admin2.id} .toggle-user-enabled-btn").click
      expect(page).to have_current_path(new_user_session_path)
    end
  end

  describe "toggle admin" do
    it "allows the admin to toggle a regular user into becoming an admin" do
      expect(page).to have_css(".user_#{user.id}")
      expect(page).to have_css(".user_#{user.id} .toggle-user-admin-btn .fa-toggle-off")
      find(".user_#{user.id} .toggle-user-admin-btn").click

      expect(page).not_to have_css(".user_#{user.id} .toggle-user-admin-btn .fa-toggle-off")
      expect(page).to have_css(".user_#{user.id} .toggle-user-admin-btn .fa-toggle-on")
      expect(page).to have_content("User '#{user.username}' is now an admin")
    end

    it "allows the admin to remove another admin" do
      user.update(admin: true)
      visit admin_users_path

      expect(page).to have_css(".user_#{user.id}")
      expect(page).to have_css(".user_#{user.id} .toggle-user-admin-btn .fa-toggle-on")
      find(".user_#{user.id} .toggle-user-admin-btn").click

      expect(page).not_to have_css(".user_#{user.id} .toggle-user-admin-btn .fa-toggle-on")
      expect(page).to have_css(".user_#{user.id} .toggle-user-admin-btn .fa-toggle-off")
      expect(page).to have_content("User '#{user.username}' is no longer an admin")
    end
  end

  describe "Edit user" do
    it "allows the admin to update a user" do
      visit edit_admin_user_path(user)

      within("#edit-user-form") do
        fill_in "Email", with: "another@example.com"
        click_button "Save"
      end

      expect(page).to have_content("User '#{user.username}' was updated successfully")

      visit admin_users_path
      expect(page).to have_content("another@example.com")
    end

    it "allows admin to create bot application token" do
      bot = create(:user, bot: true)
      visit edit_admin_user_path(bot)

      find(".toggle-link-new-app-token").click

      within("#new-app-token-form") do
        expect(focused_element_id).to eq "application_token_application"
        fill_in "Application", with: "awesome-application"

        click_button "Save"
      end

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("was created successfully")
      expect(page).to have_content("awesome-application")
    end

    it "allows admin to remove bot application token" do
      bot = create(:user, bot: true)
      token = create(:application_token, user: bot)
      visit edit_admin_user_path(bot)

      click_confirm_popover(".application_token_#{token.id} button")

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("was removed successfully")
    end

    it "disallows the admin to update a user with a wrong name" do
      visit edit_admin_user_path(user)

      within("#edit-user-form") do
        fill_in "Email", with: admin.email
        click_button "Save"
      end

      expect(page).to have_content("has already been taken")
    end
  end
end
