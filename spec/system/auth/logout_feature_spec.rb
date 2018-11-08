# frozen_string_literal: true

require "rails_helper"

describe "Logout feature", type: :system, js: true do
  let!(:registry) { create(:registry) }
  let!(:user) { create(:user) }

  before do
    login_as user
    visit authenticated_root_path
  end

  it "Redirects to login screen" do
    expect(page).to have_css("#logout")
    click_link("logout")
    expect(page).to have_content("Signed out successfully")
  end

  it "After login guest redirects to login page when he attempts to access dashboard again" do
    expect(page).to have_css("#logout")
    click_link("logout")

    visit authenticated_root_path
    expect(page).to have_content("Login")
  end
end
