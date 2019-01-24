# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::UsersController do
  let(:admin) { create(:admin) }
  let(:user) { create(:user) }

  context "as admin user" do
    before do
      create(:registry)
      sign_in admin
    end

    describe "GET #index" do
      it "returns http success" do
        get admin_users_url
        expect(response).to have_http_status(:success)
      end
    end
  end

  context "not logged into portus" do
    describe "GET #index" do
      it "redirects to login page" do
        get admin_users_url
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context "as normal user" do
    before do
      sign_in user
    end

    describe "GET #index" do
      it "blocks access" do
        get admin_users_url
        expect(response.status).to eq(401)
      end
    end
  end

  context "PUT toggle admin" do
    before do
      create(:registry)
      sign_in admin
    end

    it "changes the admin value of an user" do
      put toggle_admin_admin_user_url(id: user.id), params: { format: :js }

      user.reload
      expect(user).to be_admin
      expect(response.status).to eq 200
    end

    it 'does not allow the current user to "un-admin" itself' do
      put toggle_admin_admin_user_url(id: admin.id), params: { format: :js }

      admin.reload
      expect(admin).to be_admin
      expect(response.status).to eq(403)
    end
  end

  describe "POST #create" do
    before do
      create(:registry)
      sign_in admin
    end

    it "creates new user" do
      expect do
        post admin_users_url, params: { user: {
          username:              "solomon",
          email:                 "soloman@example.org",
          password:              "password",
          password_confirmation: "password"
        }, format: :json }
      end.to change(User, :count).by(1)
    end

    it "fails to create new user without matching password" do
      expect do
        post admin_users_url, params: { user: {
          username:              "solomon",
          email:                 "soloman@example.org",
          password:              "password",
          password_confirmation: "drowssap"
        }, format: :json }
      end.not_to change(User, :count)
    end

    it "fails to create new user if check_ldap_user! fails" do
      allow_any_instance_of(::Portus::LDAP::Search).to(
        receive(:with_error_message).and_return("error message")
      )

      expect do
        post admin_users_url, params: { user: {
          username:              "solomon",
          email:                 "soloman@example.org",
          password:              "password",
          password_confirmation: "drowssap"
        }, format: :json }
      end.not_to change(User, :count)
    end
  end

  describe "GET #edit" do
    before do
      create(:registry)
      sign_in admin
    end

    it "returns with a failure if the current user tries to edit himself" do
      get edit_admin_user_url(id: admin.id)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns success when editing another user" do
      get edit_admin_user_url(id: user.id)
      expect(response).to have_http_status(:success)
    end
  end
end
