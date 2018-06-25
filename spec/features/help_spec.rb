# frozen_string_literal: true

require "rails_helper"

describe "Help page" do
  describe "API documentation support" do
    let!(:registry) { create(:registry) }
    let!(:user)     { create(:admin)    }

    before do
      login_as user, scope: :user
    end

    it "A user can go to the API documentation" do
      visit help_index_path
      click_link("API Documentation")

      expect(page).to have_content("Swagger")
      expect(page).to have_current_path("/documentation")
    end
  end
end
