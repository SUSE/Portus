require "rails_helper"

feature "custom error handler page" do
  describe "with custom handler setup" do

    around :each do |example|
      Rails.application.config.consider_all_requests_local = false
      Rails.application.config.action_dispatch.show_exceptions = true
      Rails.env = ActiveSupport::StringInquirer.new("production")
      example.run
      Rails.application.config.consider_all_requests_local = true
      Rails.application.config.action_dispatch.show_exceptions = false
      Rails.env = ActiveSupport::StringInquirer.new("test")
    end

    scenario "when no permissions routes to custom error page" do
      visit "/teams/show?id=1234"
      expect(page).to have_content("Ops... something went wrong...")
    end

    scenario "when no database routes to custom error page" do
      ActiveRecord::Base.connection.disconnect!
      visit "/"
      expect(page).to have_content("Ops... something went wrong...")
    end

  end
end
