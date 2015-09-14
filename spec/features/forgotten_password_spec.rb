require "rails_helper"

feature "Forgotten password support" do
  let!(:user) { create(:admin) }

  before :each do
    APP_CONFIG["email"] = {
      "from"     => "test@example.com",
      "name"     => "Portus",
      "reply_to" => "no-reply@example.com"
    }
    ActionMailer::Base.deliveries.clear
  end

  scenario "gives the user a link to reset their password", js: true do
    visit new_user_session_path
    expect(page).to_not have_content("Did you forget your password?")

    fill_in "Username", with: "random"
    fill_in "Password", with: "12341234"
    click_button "Login"

    expect(current_path).to eq new_user_session_path
    expect(page).to have_content("Did you forget your password?")
    click_link("Did you forget your password?")
    expect(current_path).to eq new_user_password_path
  end

  scenario "sends the reset email when appropiate", js: true do
    visit new_user_password_path

    fill_in "Email", with: "random@example.com"
    click_button "Reset password"
    expect(current_path).to eq new_user_password_path
    expect(page).to have_content("Email not found")

    fill_in "Email", with: user.email
    click_button "Reset password"
    expect(current_path).to eq new_user_session_path
    expect(page).to have_content("You will receive an email with instructions on " \
      "how to reset your password in a few minutes.")

    # The email has been sent.
    mail = ActionMailer::Base.deliveries.first
    expect(mail.to).to match_array [user.email]
  end
end
