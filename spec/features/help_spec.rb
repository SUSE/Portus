require "rails_helper"

feature "Help page" do
  describe "API documentation support" do
    let!(:registry) { create(:registry) }
    let!(:user)     { create(:admin)    }

    before do
      login_as user, scope: :user
    end

    scenario "A user can go to the API documentation", js: true do
      visit help_index_path
      click_link("API Documentation")

      expect(page).to have_http_status(200)
      expect(page).to have_current_path("/api/documentation")
    end
  end
end
