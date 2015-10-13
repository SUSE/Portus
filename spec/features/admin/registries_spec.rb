require "rails_helper"

feature "Admin - Registries panel" do
  let!(:admin) { create(:admin) }

  before do
    login_as admin
  end

  describe "#force_registry_config!" do
    it "redirects to new_admin_registry_path if no registry has been configured", js: true do
      visit authenticated_root_path
      expect(current_path).to eq new_admin_registry_path
    end
  end

  describe "update" do
    let!(:registry) { create(:registry) }

    before :each do
      visit edit_admin_registry_path(registry.id)
    end

    it "does not show the hostname if there are repositories", js: true do
      expect(page).to have_css("#registry_hostname")

      create(:repository)
      visit edit_admin_registry_path(registry.id)

      expect(page).to_not have_css("#registry_hostname")
    end

    it "updates as expected", js: true do
      fill_in "registry_hostname", with: "lala"
      click_button "Update"

      expect(page).to have_content("Registry updated successfully!")
      expect(current_path).to eq admin_registries_path
      registry.reload
      expect(registry.hostname).to eq "lala"
    end
  end
end
