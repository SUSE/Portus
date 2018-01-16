# frozen_string_literal: true

require "rails_helper"

describe "custom error handler page" do
  describe "with custom handler setup" do
    around do |example|
      Rails.application.config.consider_all_requests_local = false
      Rails.application.config.action_dispatch.show_exceptions = true
      Rails.env = ActiveSupport::StringInquirer.new("production")
      example.run
    ensure
      Rails.application.config.consider_all_requests_local = true
      Rails.application.config.action_dispatch.show_exceptions = false
      Rails.env = ActiveSupport::StringInquirer.new("test")
    end

    it "when no permissions routes to custom error page" do
      visit "/teams/show?id=1234"
      expect(page).to have_content(/Something's wrong/)
    end

    it "when no database routes to custom error page" do
      ActiveRecord::Base.connection.disconnect!
      visit "/"
      expect(page).to have_content(/Something's wrong/)
    end
  end
end
