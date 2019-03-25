# frozen_string_literal: true

require "rails_helper"

describe Auth::OmniauthRegistrationsController do
  context "without omniauth session variable setting," do
    it "GET #new redirect to /users/sign_in" do
      visit users_oauth_url
      expect(page).to have_current_path(new_user_session_path)
    end

    it "redirects also when trying to call a callback directly with no data" do
      allow_any_instance_of(Auth::OmniauthCallbacksController).to(
        receive(:action_name).and_return("google_oauth2")
      )
      allow_any_instance_of(Auth::OmniauthCallbacksController).to(
        receive(:omniauth_data).and_return(nil)
      )

      APP_CONFIG["oauth"]["google_oauth2"] = { "enabled" => true }
      OmniAuth.config.mock_auth[:google_oauth2] = nil
      Rails.application.env_config["omniauth.auth"] = nil

      visit user_google_oauth2_omniauth_callback_url
      expect(page).to have_current_path(new_user_session_path)
    end
  end

  describe "google_auth2" do
    let(:google_mock_data) do
      {
        provider:    :google_oauth2,
        uid:         "12345",
        info:        { email: "testuser@email.net" },
        credentials: {
          token:         "abcdefg12345",
          refresh_token: "12345abcdefg",
          expires_at:    Time.zone.now
        }
      }
    end

    before do
      APP_CONFIG["oauth"]["google_oauth2"] = {
        "enabled" => true,
        "id"      => "id",
        "secret"  => "secret",
        "domain"  => "",
        "options" => {}
      }

      # Magic for Devise.
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]

      # Magic for omniauth.
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(google_mock_data)
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
    end

    context "with no configured domain" do
      it "when user doesn't exist, redirect to /users/oauth" do
        visit root_path
        click_link("Google")
        expect(page).to have_content("Create account")
        expect(page).to have_selector("#user_username[value='testuser']")
      end

      it "when user doesn't exist, we can create it afterwards" do
        visit root_path
        click_link("Google")
        click_button("Create account")
        expect(User.find_by(username: "testuser")).not_to be_nil
      end

      it "when user exists, sign in and redirect to /" do
        create :user, email: "testuser@email.net"

        visit root_path
        click_link("Google")
        expect(page).to have_current_path(authenticated_root_path)
        expect(page).to have_content("Successfully authenticated from Google oauth2 account")
      end

      it "redirects to /uses/oauth if there was a problem when entering the user" do
        allow_any_instance_of(User).to receive(:persisted?).and_return(false)
        visit root_path
        click_link("Google")
        click_button("Create account")
        expect(page).to have_current_path(users_oauth_url)
      end
    end

    context "with a configured domain" do
      it "when domain matches, redirect to /users/oauth" do
        APP_CONFIG["oauth"]["google_oauth2"]["domain"] = "email.net"

        visit root_path
        click_link("Google")
        expect(page).to have_content("Create account")
        expect(page).to have_selector("#user_username[value='testuser']")
      end

      it "when domain doesn't match, redirect to /users/sign_in" do
        APP_CONFIG["oauth"]["google_oauth2"]["domain"] = "domain.net"

        visit root_path
        click_link("Google")
        expect(page).to have_content("Email addresses on the domain email.net aren't allowed")
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe "#open_id" do
    let(:openid_mock_data) do
      {
        provider: :open_id,
        uid:      "12345",
        info:     { email: "testuser@email.net" }
      }
    end

    before do
      APP_CONFIG["oauth"]["open_id"] = {
        "enabled"    => true,
        "identifier" => "",
        "domain"     => ""
      }

      # Magic for Devise.
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]

      # Magic for omniauth.
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:open_id] = OmniAuth::AuthHash.new(openid_mock_data)
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:open_id]
    end

    it "signs in and redirects to / when user exists" do
      create :user, email: "testuser@email.net"

      visit root_path
      click_link("Open Id")
      expect(page).to have_current_path(authenticated_root_path)
      expect(page).to have_content("Successfully authenticated from Open id account")
    end
  end

  describe "openid_connect" do
    let(:openid_connect_mock_data) do
      {
        provider:    :openid_connect,
        uid:         "12345",
        info:        {
          email: "testuser@email.net",
          name:  "John Smith"
        },
        credentials: {
          token:         "abcdefg12345",
          refresh_token: "12345abcdefg",
          expires_at:    Time.zone.now
        }
      }
    end

    before do
      APP_CONFIG["oauth"]["openid_connect"] = {
        "enabled" => true
      }

      # Magic for Devise.
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]

      # Magic for omniauth.
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:openid_connect] = OmniAuth::AuthHash.new(openid_connect_mock_data)
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:openid_connect]
    end

    it "when user doesn't exist, redirect to /users/oauth" do
      visit root_path
      click_link("Open Id Connect")

      expect(page).to have_content("Create account")
      expect(page).to have_selector("#user_username[value='testuser']")
      expect(page).to have_selector("#user_display_name[value='John Smith']")
    end

    it "when user doesn't exist, we can create it afterwards" do
      visit root_path
      click_link "Open Id Connect"
      click_button "Create account"

      expect(User.find_by(username: "testuser")).not_to be_nil
    end

    it "when user exists, sign in and redirect to /" do
      create :user, email: "testuser@email.net"
      visit root_path
      click_link "Open Id Connect"

      expect(page).to have_current_path(authenticated_root_path)
      expect(page).to have_content("Successfully authenticated from Openid connect account")
    end

    it "redirects to /uses/oauth if there was a problem when entering the user" do
      allow_any_instance_of(User).to receive(:persisted?).and_return(false)
      visit root_path
      click_link "Open Id Connect"
      click_button "Create account"

      expect(page).to have_current_path(users_oauth_url)
    end
  end

  describe "#github" do
    let(:github_mock_data) do
      {
        provider:    :github,
        uid:         "12345",
        credentials: { token: "1234567890" },
        info:        { email: "testuser@email.net" }
      }
    end

    before do
      APP_CONFIG["oauth"]["github"] = {
        "enabled"      => true,
        "organization" => "",
        "domain"       => "",
        "team"         => ""
      }

      # Magic for Devise.
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]

      # Magic for omniauth.
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(github_mock_data)
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:github]

      create :user, email: "testuser@email.net"
    end

    it "signs in and redirects to / when user exists" do
      visit root_path
      click_link("Github")
      expect(page).to have_current_path(authenticated_root_path)
      expect(page).to have_content("Successfully authenticated from Github account")
    end

    context "when organization was set" do
      it "when organization matches, sign in and redirect to /" do
        APP_CONFIG["oauth"]["github"]["organization"] = "org"

        visit root_path
        VCR.use_cassette("api_github_orgs") { click_link("Github") }

        expect(page).to have_current_path(authenticated_root_path)
        expect(page).to have_content("Successfully authenticated from Github account")
      end

      it "when organization doesn't match, redirect to /users/sign_in" do
        APP_CONFIG["oauth"]["github"]["organization"] = "wrong_org"

        visit root_path
        VCR.use_cassette("api_github_orgs") { click_link("Github") }

        expect(page).to have_current_path(new_user_session_path)
      end
    end

    context "when both the team and organization are set" do
      it "when team and organization match, sign in and redirect to /" do
        APP_CONFIG["oauth"]["github"]["organization"] = "org"
        APP_CONFIG["oauth"]["github"]["team"] = "team"

        visit root_path
        VCR.use_cassette("api_github_teams") { click_link("Github") }

        expect(page).to have_current_path(authenticated_root_path)
        expect(page).to have_content("Successfully authenticated from Github account")
      end

      it "when organization matches but team doesn't match, redirect to /users/sign_in" do
        APP_CONFIG["oauth"]["github"]["organization"] = "org"
        APP_CONFIG["oauth"]["github"]["team"] = "wrong_team"

        visit root_path
        VCR.use_cassette("api_github_teams") { click_link("Github") }

        expect(page).to have_current_path(new_user_session_path)
      end

      it "when team matches but organization doen't match, redirect to /users/sign_in" do
        APP_CONFIG["oauth"]["github"]["organization"] = "wrong_org"
        APP_CONFIG["oauth"]["github"]["team"] = "team"

        visit root_path
        VCR.use_cassette("api_github_teams") { click_link("Github") }

        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe "Custom #github" do
    let(:github_mock_data) do
      {
        provider:    :github,
        uid:         "12345",
        credentials: { token: "1234567890" },
        info:        { email: "testuser@email.net" }
      }
    end

    before do
      APP_CONFIG["oauth"]["github"] = {
        "enabled"      => true,
        "server"       => "github.com",
        "organization" => "",
        "domain"       => "",
        "team"         => ""
      }

      # Magic for Devise.
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]

      # Magic for omniauth.
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(github_mock_data)
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:github]

      create :user, email: "testuser@email.net"
    end

    it "signs in and redirects to / when user exists" do
      visit root_path
      click_link("Github")
      expect(page).to have_current_path(authenticated_root_path)
      expect(page).to have_content("Successfully authenticated from Github account")
    end

    context "when organization was set" do
      it "when organization matches, sign in and redirect to /" do
        APP_CONFIG["oauth"]["github"]["organization"] = "org"

        visit root_path
        VCR.use_cassette("api_github_orgs") { click_link("Github") }

        expect(page).to have_current_path(authenticated_root_path)
        expect(page).to have_content("Successfully authenticated from Github account")
      end

      it "when organization doesn't match, redirect to /users/sign_in" do
        APP_CONFIG["oauth"]["github"]["organization"] = "wrong_org"

        visit root_path
        VCR.use_cassette("api_github_orgs") { click_link("Github") }

        expect(page).to have_current_path(new_user_session_path)
      end
    end

    context "when both the team and organization are set" do
      it "when team and organization match, sign in and redirect to /" do
        APP_CONFIG["oauth"]["github"]["organization"] = "org"
        APP_CONFIG["oauth"]["github"]["team"] = "team"

        visit root_path
        VCR.use_cassette("api_github_teams") { click_link("Github") }

        expect(page).to have_current_path(authenticated_root_path)
        expect(page).to have_content("Successfully authenticated from Github account")
      end

      it "when organization matches but team doesn't match, redirect to /users/sign_in" do
        APP_CONFIG["oauth"]["github"]["organization"] = "org"
        APP_CONFIG["oauth"]["github"]["team"] = "wrong_team"

        visit root_path
        VCR.use_cassette("api_github_teams") { click_link("Github") }

        expect(page).to have_current_path(new_user_session_path)
      end

      it "when team matches but organization doen't match, redirect to /users/sign_in" do
        APP_CONFIG["oauth"]["github"]["organization"] = "wrong_org"
        APP_CONFIG["oauth"]["github"]["team"] = "team"

        visit root_path
        VCR.use_cassette("api_github_teams") { click_link("Github") }

        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe "Custom Gitlab" do
    let(:gitlab_mock_data) do
      {
        provider:    :gitlab,
        uid:         "12345",
        credentials: { token: "1234567890" },
        info:        { email: "testuser@email.net" }
      }
    end

    before do
      APP_CONFIG["oauth"]["gitlab"] = {
        "enabled" => true,
        "server"  => "https://gitlab.com",
        "group"   => "",
        "domain"  => ""
      }

      # Magic for Devise.
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]

      # Magic for omniauth.
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:gitlab] = OmniAuth::AuthHash.new(gitlab_mock_data)
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:gitlab]

      create :user, email: "testuser@email.net"
    end

    context "with group settled" do
      it "when group matches, sign in and redirect to /" do
        APP_CONFIG["oauth"]["gitlab"]["group"] = "group"

        visit root_path
        VCR.use_cassette("api_gitlab_groups") { click_link("Gitlab") }

        expect(page).to have_current_path(authenticated_root_path)
        expect(page).to have_content("Successfully authenticated from Gitlab account")
      end

      it "when group doesn't match, redirect to /users/sign_in" do
        APP_CONFIG["oauth"]["gitlab"]["group"] = "wrong_group"

        visit root_path
        VCR.use_cassette("api_gitlab_groups") { click_link("Gitlab") }

        expect(page).to have_current_path(new_user_session_path)
      end
    end

    it "when group isn't set, sign in and redirect to /" do
      visit root_path
      click_link("Gitlab")
      expect(page).to have_current_path(authenticated_root_path)
      expect(page).to have_content("Successfully authenticated from Gitlab account")
    end
  end

  describe "Gitlab" do
    let(:gitlab_mock_data) do
      {
        provider:    :gitlab,
        uid:         "12345",
        credentials: { token: "1234567890" },
        info:        { email: "testuser@email.net" }
      }
    end

    before do
      APP_CONFIG["oauth"]["gitlab"] = {
        "enabled" => true,
        "server"  => "",
        "group"   => "",
        "domain"  => ""
      }

      # Magic for Devise.
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]

      # Magic for omniauth.
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:gitlab] = OmniAuth::AuthHash.new(gitlab_mock_data)
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:gitlab]

      create :user, email: "testuser@email.net"
    end

    context "with group settled" do
      it "when group matches, sign in and redirect to /" do
        APP_CONFIG["oauth"]["gitlab"]["group"] = "group"

        visit root_path
        VCR.use_cassette("api_gitlab_groups") { click_link("Gitlab") }

        expect(page).to have_current_path(authenticated_root_path)
        expect(page).to have_content("Successfully authenticated from Gitlab account")
      end

      it "when group doesn't match, redirect to /users/sign_in" do
        APP_CONFIG["oauth"]["gitlab"]["group"] = "wrong_group"

        visit root_path
        VCR.use_cassette("api_gitlab_groups") { click_link("Gitlab") }

        expect(page).to have_current_path(new_user_session_path)
      end
    end

    it "when group isn't set, sign in and redirect to /" do
      visit root_path
      click_link("Gitlab")
      expect(page).to have_current_path(authenticated_root_path)
      expect(page).to have_content("Successfully authenticated from Gitlab account")
    end
  end

  describe "Bitbucket" do
    let(:bitbucket_mock_data) do
      {
        provider:    :bitbucket,
        uid:         "12345",
        credentials: { token: "1234567890" },
        info:        { email: "testuser@email.net" }
      }
    end

    before do
      APP_CONFIG["oauth"]["bitbucket"] = {
        "enabled" => true,
        "domain"  => "",
        "options" => { "team" => "" }
      }

      # Magic for Devise.
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]

      # Magic for omniauth.
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:bitbucket] = OmniAuth::AuthHash.new(bitbucket_mock_data)
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:bitbucket]

      create :user, email: "testuser@email.net"
    end

    context "when team is set" do
      it "when team matches, sign in and redirect to /" do
        APP_CONFIG["oauth"]["bitbucket"]["options"]["team"] = "atlant-service"

        visit root_path
        click_link("Bitbucket")

        expect(page).to have_current_path(authenticated_root_path)
        expect(page).to have_content("Successfully authenticated from Bitbucket account")
      end
    end
  end
end
