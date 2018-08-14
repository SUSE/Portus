# frozen_string_literal: true

require "rails_helper"

describe "Gravatar support" do
  let!(:registry) { create(:registry) }
  let!(:user) { create(:user) }

  before do
    login user
  end

  it "If gravatar support is on, there should be an image" do
    APP_CONFIG["gravatar"] = { "enabled" => true }
    visit root_path
    expect(page).to have_selector(".user-header img")
  end

  it "If gravatar suppor is disabled, there should be an icon" do
    APP_CONFIG["gravatar"] = { "enabled" => false }
    visit root_path
    expect(page).to have_selector(".user-header .user-picture")
  end
end
