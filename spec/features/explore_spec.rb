require "rails_helper"

feature "Explore feature" do
  let!(:registry) { create(:registry) }
  let!(:user)     { create(:user) }

  before do
    # Default value
    APP_CONFIG["anonymous_browsing"] = { "enabled" => true }
  end

  context "Access" do
    before do
      visit new_user_session_path
    end

    it "allows access to the explore page when enabled" do
      find("#explore").click
      expect(page).to have_current_path(explore_index_path)
    end

    it "redirects the user if access is not allowed" do
      APP_CONFIG["anonymous_browsing"] = { "enabled" => false }
      visit new_user_session_path

      expect(first("#explore")).to be_nil
    end
  end

  context "Explore" do
    let!(:registry)   { create(:registry, hostname: "registry.test.lan") }
    let!(:user)       { create(:admin) }
    let!(:repository) { create(:repository, namespace: registry.global_namespace, name: "repo") }
    let!(:tag)        { create(:tag, name: "tag0", repository: repository) }
    let!(:tag1)       { create(:tag, name: "tag1", repository: repository) }

    before do
      visit explore_index_path
    end

    it "allows people to search for repositories", js: true do
      fill_in "explore_search", with: "repo"
      click_button "Search"

      expect(page).to have_content("1 repository was found")
      expect(page).to have_content("repo")
      expect(page).to have_content("tag0")
      expect(page).to have_content("tag1")
    end
  end
end
