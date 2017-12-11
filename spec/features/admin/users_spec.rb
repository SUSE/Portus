# frozen_string_literal: true

require "rails_helper"

describe "Admin - Users panel" do
  let!(:registry) { create(:registry) }
  let!(:admin) { create(:admin) }
  let!(:user) { create(:user) }

  before do
    login_as admin
    visit admin_users_path
  end

  describe "create users", js: true do
    it "admin creates a user" do
      visit new_admin_user_path

      fill_in "Username",              with: "username"
      fill_in "Email",                 with: "email@email.com"
      fill_in "user[password]",        with: "password123"
      fill_in "Password confirmation", with: "password123"

      click_button "Create"

      expect(page).to have_current_path(admin_users_path)
      expect(page).to have_content("User 'username' was created successfully")
    end

    it "admin adds back a removed user" do
      expect(page).to have_css("#user_#{user.id}")

      find("#user_#{user.id} .remove-btn").click
      find("#user_#{user.id} .btn-confirm-remove").click

      expect(page).to have_content("User '#{user.username}' was removed successfully")

      visit new_admin_user_path

      fill_in "Username",              with: user.username
      fill_in "Email",                 with: user.email
      fill_in "user[password]",        with: "password123"
      fill_in "Password confirmation", with: "password123"

      click_button "Create"

      expect(page).to have_current_path(admin_users_path)
      expect(page).to have_content("User '#{user.username}' was created successfully")
    end
  end

  describe "remove users" do
    it "allows the admin to remove other users", js: true do
      expect(page).to have_css("#user_#{user.id}")
      expect(page).to have_content(user.username)

      find("#user_#{user.id} .remove-btn").click
      find("#user_#{user.id} .btn-confirm-remove").click

      expect { User.find(user.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(page).to have_content("User '#{user.username}' was removed successfully")
    end

    it "allows the admin to remove other users from the show page", js: true do
      visit edit_admin_user_path(user.id)

      expect(page).not_to have_css("#user_#{user.id}")
      expect(page).to have_content(user.username)

      find(".btn-danger").click
      expect(page).to have_current_path(admin_users_path)

      expect { User.find(user.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect(page).to have_content("User '#{user.username}' was removed successfully")
      expect(page).not_to have_css("#user_#{user.id}")
    end
  end

  describe "disable users" do
    it "allows the admin to disable other users", js: true do
      expect(page).to have_css("#user_#{user.id}")
      find("#user_#{user.id} .enabled-btn").click

      expect(page).to have_css("#user_#{user.id} .fa-toggle-off")
      expect(page).to have_content("User '#{user.username}' has been disabled.")
    end

    it "allows the admin to enable back a user", js: true do
      user.update_attributes(enabled: false)
      visit admin_users_path

      expect(page).to have_css("#user_#{user.id}")
      find("#user_#{user.id} .enabled-btn").click

      expect(page).to have_css("#user_#{user.id} .fa-toggle-on")
      expect(page).to have_content("User '#{user.username}' has been enabled.")
    end
  end

  describe "toggle admin" do
    it "allows the admin to toggle a regular user into becoming an admin", js: true do
      expect(page).to have_css("#user_#{user.id}")
      expect(page).to have_css("#user_#{user.id} .admin-btn .fa-toggle-off")
      find("#user_#{user.id} .admin-btn").click

      expect(page).not_to have_css("#user_#{user.id} .admin-btn .fa-toggle-off")
      expect(page).to have_css("#user_#{user.id} .admin-btn .fa-toggle-on")
      expect(page).to have_content("User '#{user.username}' is now an admin")
    end

    it "allows the admin to remove another admin", js: true do
      user.update_attributes(admin: true)
      visit admin_users_path

      expect(page).to have_css("#user_#{user.id}")
      expect(page).to have_css("#user_#{user.id} .admin-btn .fa-toggle-on")
      find("#user_#{user.id} .admin-btn").click

      expect(page).not_to have_css("#user_#{user.id} .admin-btn .fa-toggle-on")
      expect(page).to have_css("#user_#{user.id} .admin-btn .fa-toggle-off")
      expect(page).to have_content("User '#{user.username}' is no longer an admin")
    end
  end

  describe "Edit user" do
    it "allows the admin to update a user", js: true do
      visit edit_admin_user_path(user)

      fill_in "Email", with: "another@example.com"
      click_button "Update"

      expect(page).to have_content("another@example.com")
      expect(page).to have_content("User '#{user.username}' was updated successfully")
    end

    it "disallows the admin to update a user with a wrong name", js: true do
      visit edit_admin_user_path(user)

      fill_in "Email", with: admin.email
      click_button "Update"

      expect(page).to have_content("has already been taken")
    end
  end
end
