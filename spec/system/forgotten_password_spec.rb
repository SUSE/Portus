# frozen_string_literal: true

require "rails_helper"

describe "Forgotten password support" do
  let!(:user)   { create(:admin) }
  let!(:portus) { create(:admin, username: "portus", email: "portus@portus.com") }

  before do
    APP_CONFIG["signup"] = { "enabled" => true }
    APP_CONFIG["email"]  = {
      "from"     => "test@example.com",
      "name"     => "Portus",
      "reply_to" => "no-reply@example.com",
      "smtp"     => { "enabled" => false }
    }
    ActionMailer::Base.deliveries.clear
  end

  it "gives the user a link to reset their password" do
    visit new_user_session_path
    expect(page).to have_content("I forgot my password")
  end

  it "prevents the portus user from resetting the password" do
    visit new_user_password_path

    fill_in "Email", with: "portus@portus.com"
    click_button "Reset password"
    expect(page).to have_content("Action not allowed on this user")
  end

  it "sends the reset email when appropiate" do
    visit new_user_password_path

    fill_in "Email", with: "random@example.com"
    click_button "Reset password"
    expect(page).to have_current_path(new_user_password_path)
    expect(page).to have_content("Email not found")

    fill_in "Email", with: user.email
    click_button "Reset password"
    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_content("You will receive an email with instructions on " \
      "how to reset your password in a few minutes.")

    # The email has been sent.
    mail = ActionMailer::Base.deliveries.first
    expect(mail.to).to match_array [user.email]
  end
end
