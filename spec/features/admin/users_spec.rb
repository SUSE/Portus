require "rails_helper"

feature "Admin - Users panel" do
  let!(:registry) { create(:registry) }
  let!(:admin) { create(:admin) }
  let!(:user) { create(:user) }

  before do
    login_as admin, scope: :user
    visit admin_users_path
  end

  describe "disable users" do
    scenario "allows the admin to disable other users", js: true do
      expect(page).to have_css("#user_#{user.id}")
      find("#user_#{user.id} .enabled-btn").click

      wait_for_effect_on("#user_#{user.id}")

      expect(page).to_not have_css("#user_#{user.id}")
      wait_for_effect_on("#alert")
      expect(page).to have_content("User '#{user.username}' has been disabled.")
    end
  end
end
