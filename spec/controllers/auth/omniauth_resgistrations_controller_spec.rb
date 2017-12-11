# frozen_string_literal: true

require "rails_helper"

describe Auth::OmniauthRegistrationsController do
  context "without omniauth session variable setting," do
    it "GET #new redirect to /users/sign_in" do
      get :new
      expect(response).to redirect_to new_user_session_url
    end
  end

  context "with omniauth session variable setting," do
    before do
      session["omniauth.auth"] = {
        "info"     => {
          "username" => "login_name",
          "name"     => "User Name",
          "email"    => "test@mail.net"
        },
        "provider" => "google_oauth2",
        "uid"      => "12345"
      }
    end

    context "GET #new" do
      render_views

      it "render omiauth user registration form" do
        get :new
        expect(response).to have_http_status :success
        expect(response.body).to include "login_name"
      end

      it "when username exists suggest other username" do
        create :user, username: "login_name"
        get :new
        expect(response).to have_http_status :success
        expect(response.body).to include "login_name_01"
      end
    end

    context "POST #create" do
      let(:user) { { username: "login_name", display_name: "User Name" } }

      it "creates new user" do
        expect { post :create, user: user }.to change { User.count }.by 1
        expect(response).to redirect_to authenticated_root_url
      end

      it "when user exists, redirect to /users/oauth" do
        create :user, email: "test@mail.net"
        expect { post :create, user: user }.to change { User.count }.by 0
        expect(response).to redirect_to users_oauth_url
      end

      it "when display name is already used, redirect to /users/oauth" do
        create :user, display_name: "User Name"
        expect { post :create, user: user }.to change { User.count }.by 0
        expect(response).to redirect_to users_oauth_url
      end
    end
  end
end
