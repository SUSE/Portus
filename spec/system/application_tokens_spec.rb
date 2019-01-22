# frozen_string_literal: true

require "rails_helper"

describe "Application tokens" do
  let!(:user) { create(:user) }

  before do
    login_as user, scope: :user
  end

  describe "ApplicationTokens#create" do
    it "As an user I can create a new token", js: true do
      visit edit_user_registration_path
      find(".toggle-link-new-app-token").click

      expect(focused_element_id).to eq "application_token_application"
      fill_in "Application", with: "awesome-application"

      click_button "Save"

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("was created successfully")
      expect(page).to have_content("awesome-application")
    end

    it "As an user I cannot create two tokens with the same name", js: true do
      create(:application_token, application: "awesome-application", user: user)

      visit edit_user_registration_path
      find(".toggle-link-new-app-token").click

      expect(focused_element_id).to eq "application_token_application"
      fill_in "Application", with: "awesome-application"

      click_button "Save"

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("Application has already been taken")
    end

    it "As an user the create new token link is disabled when I reach the limit", js: true do
      create_list(:application_token, User::APPLICATION_TOKENS_MAX - 1, user: user)

      visit edit_user_registration_path
      find(".toggle-link-new-app-token").click

      expect(focused_element_id).to eq "application_token_application"
      fill_in "Application", with: "awesome-application"

      click_button "Save"

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("was created successfully")
      expect(page).to have_content("awesome-application")
      expect(page).not_to have_css(".toggle-link-new-app-token")
    end

    it "As an user I cannot create tokens once I reach my limit", js: true do
      create_list(:application_token, User::APPLICATION_TOKENS_MAX, user: user)

      visit edit_user_registration_path
      expect(page).not_to have_css(".toggle-link-new-app-token")
    end
  end

  describe "ApplicationTokens#destroy" do
    it "As an user I can revoke a token", js: true do
      token = create(:application_token, user: user)

      visit edit_user_registration_path

      click_confirm_popover(".application_token_#{token.id} button")

      expect(page).to have_css("#float-alert")
      expect(page).to have_content("was removed successfully")
    end
  end
end
