# frozen_string_literal: true

require "rails_helper"

describe Auth::OmniauthCallbacksController do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET #google_oauth2" do
    before do
      APP_CONFIG["oauth"] = { "google_oauth2" => { "domain" => "" } }
    end

    context "when there is no data from provider," do
      it "redirect to /users/sign_in" do
        get :google_oauth2
        expect(response).to redirect_to new_user_session_url
        expect(subject.current_user).to be nil
      end
    end

    context "when got data from provider," do
      before do
        OmniAuth.config.add_mock(:google_oauth2,
                                 provider: "google_oauth2",
                                 uid:      "12345",
                                 info:     { email: "test@mail.net" })
        request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
      end

      context "with domain isn't setted," do
        it "when user doesn't exist, redirect to /users/oauth" do
          get :google_oauth2
          expect(response).to redirect_to users_oauth_url
        end

        it "when user exists, sign in and redirect to /" do
          create :user, email: "test@mail.net"
          get :google_oauth2
          expect(response).to redirect_to authenticated_root_url
          expect(subject.current_user).not_to eq(nil)
        end
      end

      context "with domain is setted," do
        it "when domain matches, redirect to /users/oauth" do
          APP_CONFIG["oauth"]["google_oauth2"]["domain"] = "mail.net"
          get :google_oauth2
          expect(response).to redirect_to users_oauth_url
        end

        it "when domain doesn't match, redirect to /users/sign_in" do
          APP_CONFIG["oauth"]["google_oauth2"]["domain"] = "domain.net"
          get :google_oauth2
          expect(response).to redirect_to new_user_session_url
          expect(subject.current_user).to be nil
        end
      end
    end
  end

  describe "GET #open_id" do
    before do
      APP_CONFIG["oauth"] = { "open_id" => { "domain" => "" } }
      OmniAuth.config.add_mock(:open_id,
                               provider: "open_id",
                               uid:      "12345",
                               info:     { email: "test@mail.net" })
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:open_id]
    end

    it "sign in and redirect to /" do
      create :user, email: "test@mail.net"
      get :open_id
      expect(response).to redirect_to authenticated_root_url
      expect(subject.current_user).not_to eq(nil)
    end
  end

  describe "GET #github" do
    before do
      APP_CONFIG["oauth"] = { "github" => {
        "domain"       => "",
        "organization" => "",
        "team"         => ""
      } }

      OmniAuth.config.add_mock(:github,
                               provider:    "github",
                               uid:         "12345",
                               credentials: { token: "1234567890" },
                               info:        { email: "test@mail.net" })
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:github]
      create :user, email: "test@mail.net"
    end

    it "with team and organization aren't setted, sign in and redirect to /" do
      get :github
      expect(response).to redirect_to authenticated_root_url
      expect(subject.current_user).not_to eql nil
    end

    context "with organization is setted and team isn't setted," do
      it "when organization matches, sign in and redirect to /" do
        APP_CONFIG["oauth"]["github"]["organization"] = "org"
        VCR.use_cassette "api_github_orgs" do
          get :github
        end
        expect(response).to redirect_to authenticated_root_url
        expect(subject.current_user).not_to eql nil
      end

      it "when organization doesn't match, redirect to /users/sign_in" do
        APP_CONFIG["oauth"]["github"]["organization"] = "wrong_org"
        VCR.use_cassette "api_github_orgs" do
          get :github
        end
        expect(response).to redirect_to new_user_session_url
        expect(subject.current_user).to be nil
      end
    end

    context "with team and organization are setted," do
      it "when team and organization match, sign in and redirect to /" do
        APP_CONFIG["oauth"]["github"]["organization"] = "org"
        APP_CONFIG["oauth"]["github"]["team"] = "team"
        VCR.use_cassette "api_github_teams" do
          get :github
        end
        expect(response).to redirect_to authenticated_root_url
        expect(subject.current_user).not_to eql nil
      end

      it "when organization matches but team doesn't match, redirect to /users/sign_in" do
        APP_CONFIG["oauth"]["github"]["organization"] = "org"
        APP_CONFIG["oauth"]["github"]["team"] = "wrong_team"
        VCR.use_cassette "api_github_teams" do
          get :github
        end
        expect(response).to redirect_to new_user_session_url
        expect(subject.current_user).to be nil
      end

      it "when team matches but organization doen't match, redirect to /users/sign_in" do
        APP_CONFIG["oauth"]["github"]["organization"] = "wrong_org"
        APP_CONFIG["oauth"]["github"]["team"] = "team"
        VCR.use_cassette "api_github_teams" do
          get :github
        end
        expect(response).to redirect_to new_user_session_url
        expect(subject.current_user).to be nil
      end
    end
  end

  describe "GET custom #gitlab" do
    before do
      APP_CONFIG["oauth"] = { "gitlab" => { "server": "https://gitlab.com",
                                            "domain" => "", "group" => "" } }
      OmniAuth.config.add_mock(:gitlab,
                               provider:    "gitlab",
                               uid:         "12345",
                               credentials: { token: "1234567890" },
                               info:        { email: "test@mail.net" })
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:gitlab]
      create :user, email: "test@mail.net"
    end

    context "CUSTOMGITLAB: with group is setted," do
      it "when group matches, sign in and redirect to /" do
        APP_CONFIG["oauth"]["gitlab"]["group"] = "group"
        VCR.use_cassette "api_gitlab_groups" do
          get :gitlab
        end
        expect(response).to redirect_to authenticated_root_url
        expect(subject.current_user).not_to eql nil
      end

      it "when group not match, redirect to /users/sign_in" do
        APP_CONFIG["oauth"]["gitlab"]["group"] = "wrong_group"
        VCR.use_cassette "api_gitlab_groups" do
          get :gitlab
        end
        expect(response).to redirect_to new_user_session_url
        expect(subject.current_user).to be nil
      end
    end

    it "when group isn't setted, sign in and redirect to /" do
      get :gitlab
      expect(response).to redirect_to authenticated_root_url
      expect(subject.current_user).not_to eql nil
    end
  end

  describe "GET #gitlab" do
    before do
      APP_CONFIG["oauth"] = { "gitlab" => { "domain" => "", "group" => "" } }
      OmniAuth.config.add_mock(:gitlab,
                               provider:    "gitlab",
                               uid:         "12345",
                               credentials: { token: "1234567890" },
                               info:        { email: "test@mail.net" })
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:gitlab]
      create :user, email: "test@mail.net"
    end

    context "with group is setted," do
      it "when group matches, sign in and redirect to /" do
        APP_CONFIG["oauth"]["gitlab"]["group"] = "group"
        VCR.use_cassette "api_gitlab_groups" do
          get :gitlab
        end
        expect(response).to redirect_to authenticated_root_url
        expect(subject.current_user).not_to eql nil
      end

      it "when group not match, redirect to /users/sign_in" do
        APP_CONFIG["oauth"]["gitlab"]["group"] = "wrong_group"
        VCR.use_cassette "api_gitlab_groups" do
          get :gitlab
        end
        expect(response).to redirect_to new_user_session_url
        expect(subject.current_user).to be nil
      end
    end

    it "when group isn't setted, sign in and redirect to /" do
      get :gitlab
      expect(response).to redirect_to authenticated_root_url
      expect(subject.current_user).not_to eql nil
    end
  end

  describe "GET #bitbucket" do
    before do
      APP_CONFIG["oauth"] = { "bitbucket" => {
        "domain" => "",
        "team"   => ""
      } }
      OmniAuth.config.add_mock(:gitlab,
                               provider:    "bitbucket",
                               uid:         "12345",
                               credentials: { token: "1234567890" },
                               info:        { email: "test@mail.net" })
      request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:gitlab]
      create :user, email: "test@mail.net"
    end

    context "when team is setted" do
      it "when team matches, sign in and redirect to /" do
        APP_CONFIG["oauth"]["bitbucket"]["team"] = "atlant-service"
        get :bitbucket
        expect(response).to redirect_to authenticated_root_url
        expect(subject.current_user).not_to eql nil
      end
    end
  end
end
