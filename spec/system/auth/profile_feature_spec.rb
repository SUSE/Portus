# frozen_string_literal: true

require "rails_helper"

describe "Update password feature" do
  let!(:user) { create(:admin) }

  before do
    login_as user, scope: :user
    visit edit_user_registration_path
  end

  # Changing the email

  it "enables the button if the user pressed a key", js: true do
    # Change the contents and see that it gets enabled.
    expect(page).to have_button("Save", disabled: true)
    fill_in "Email", with: "another@example.com"
    expect(page).to have_button("Save")

    # Click the button, the contents should be updated.
    click_button("Save")
    expect(page).to have_current_path(edit_user_registration_path)
    expect(page).to have_button("Save", disabled: true)
    expect(find("#user_email").value).to eq "another@example.com"
  end

  it "disables the 'Update' button if email becomes empty", js: true do
    expect(page).to have_button("Save", disabled: true)
    fill_in "Email", with: ""
    expect(page).to have_button("Save", disabled: true)
  end

  it "enables the 'Update' button if email != empty", js: true do
    expect(page).to have_button("Save", disabled: true)
    fill_in "Email", with: "email@email.com"
    expect(page).to have_button("Save")
  end

  it "disables the 'Update' button if email == original value", js: true do
    expect(page).to have_button("Save", disabled: true)
    fill_in "Email", with: "email@email.com"
    expect(page).to have_button("Save")
    fill_in "Email", with: user.email
    expect(page).to have_button("Save", disabled: true)
  end

  it "keeps the 'Update' button disabled if no changes", js: true do
    expect(page).to have_button("Save", disabled: true)
  end

  describe "Display name enabled" do
    before do
      APP_CONFIG["display_name"] = { "enabled" => true }
      visit edit_user_registration_path
    end

    it "shows display name field", js: true do
      expect(page).to have_content("Display name")
    end

    it "keeps the 'Update' button disabled if no changes", js: true do
      expect(page).to have_button("Save", disabled: true)
    end

    it "enables the 'Update' button if display name != original value", js: true do
      expect(page).to have_button("Save", disabled: true)
      fill_in "Display name", with: "name"
      expect(page).to have_button("Save")

      click_button("Save")

      expect(page).to have_content("Profile updated successfully!")
      expect(page).to have_button("Save", disabled: true)
      clear_field("#user_display_name")
      expect(page).to have_button("Save")
    end
  end

  # Changing the password

  it "enables/disables the submit button properly", js: true do
    # By default it's disabled.
    expect(page).to have_button("Save", disabled: true)

    # Now we fill the current and the new password.
    fill_in "user_current_password", with: user.password
    fill_in "user_password", with: "12341234"
    expect(page).to have_button("Save", disabled: true)

    # We write the confirmation but it differs from the one we just wrote.
    fill_in "user_password_confirmation", with: "1234"
    expect(page).to have_button("Save", disabled: true)

    # Now we write the proper copnfirmation
    fill_in "user_password_confirmation", with: "12341234"
    expect(page).to have_button("Save")

    # Click the button and see that everything is as expected.
    click_button "Save"
    expect(page).to have_current_path(edit_user_registration_path)
    expect(User.first.valid_password?("12341234")).to be true
  end

  # Disabling user

  it "disables the current user", js: true do
    create(:admin)
    visit edit_user_registration_path

    click_button "Disable"
    expect(page).to have_current_path(root_path)
    expect(page).to have_content("Login")
  end

  it 'The "disable" pannel does not exists if it\'s the only admin' do
    expect(page).not_to have_button("Disable")
  end
end
