# frozen_string_literal: true

require "rails_helper"

describe API::V1::Users, type: :request do
  let(:user_data) do
    {
      username:     "solomon",
      email:        "solomon@example.org",
      password:     "password",
      display_name: "Solomon Gandy"
    }
  end

  before do
    @admin = create :admin
    token = create :application_token, user: @admin
    @header = build_token_header(token)

    APP_CONFIG["first_user_admin"] = { "enabled" => true }
  end

  context "GET /api/v1/users" do
    context "with data" do
      before do
        create_list(:user, 15)
      end

      it "returns list of all users (not paginated)" do
        get "/api/v1/users", params: { all: true }, headers: @header
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body).size).to eq User.count
      end

      it "returns list of users paginated" do
        get "/api/v1/users", params: { per_page: 10 }, headers: @header
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body).size).to eq 10
      end

      it "returns list of users paginated (page 2)" do
        get "/api/v1/users", params: { per_page: 10, page: 2 }, headers: @header
        expect(response).to have_http_status(:success)
        expect(JSON.parse(response.body).size).to eq 6
      end

      it "returns list of users ordered " do
        get "/api/v1/users",
            params:  { sort_attr: "id", sort_order: "desc", per_page: 10 },
            headers: @header

        users = JSON.parse(response.body)
        users.each_slice(2) do |a, b|
          expect(a["id"]).to be > b["id"]
        end
      end
    end

    it "authentication fails" do
      get "/api/v1/users"
      expect(response).to have_http_status(:unauthorized)
    end

    it "authorization fails" do
      token = create :application_token
      header = { "PORTUS-AUTH" => "#{token.user.username}:#{token.application}" }
      get "/api/v1/users", params: nil, headers: header
      expect(response).to have_http_status(:forbidden)
    end
  end

  context "GET /api/v1/users/:id" do
    let(:user) { create(:user) }

    it "returns user by id" do
      get "/api/v1/users/#{user["id"]}", params: nil, headers: @header
      expect(response).to have_http_status(:success)

      data = JSON.parse(response.body)
      expect(data["username"]).to eq user["username"]
    end

    it "authorization fails" do
      token = create :application_token
      header = { "PORTUS-AUTH" => "#{token.user.username}:#{token.application}" }
      get "/api/v1/users/#{token.user.id}", params: nil, headers: header
      expect(response).to have_http_status(:forbidden)
    end

    it "returns user by email" do
      get "/api/v1/users/#{user["email"]}", params: nil, headers: @header
      expect(response).to have_http_status(:success)

      data = JSON.parse(response.body)
      expect(data["id"]).to eq user["id"]
    end

    it "returns status 404" do
      user_id = User.maximum(:id) + 1
      get "/api/v1/users/#{user_id}", params: nil, headers: @header
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/users" do
    context "with valid params" do
      it "creates new user" do
        allow_any_instance_of(::Portus::LDAP::Search).to(
          receive(:with_error_message).and_return(nil)
        )

        post "/api/v1/users", params: { user: user_data }, headers: @header
        expect(response).to have_http_status(:created)
        expect(User.find_by(email: user_data[:email])).not_to be_nil
      end

      it "creates a new bot" do
        allow_any_instance_of(::Portus::LDAP::Search).to(
          receive(:with_error_message).and_return(nil)
        )

        data = user_data.merge(bot: true)
        post "/api/v1/users", params: { user: data }, headers: @header
        expect(User.find_by(email: data[:email]).bot).to be_truthy
      end

      it "refuses to create existing LDAP user" do
        allow_any_instance_of(::Portus::LDAP::Search).to(
          receive(:with_error_message).and_return("error message")
        )

        post "/api/v1/users", params: { user: user_data }, headers: @header
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["message"]).not_to be_nil
      end
    end

    context "with invalid params" do
      it "returns errors" do
        allow_any_instance_of(::Portus::LDAP::Search).to(
          receive(:with_error_message).and_return(nil)
        )

        post "/api/v1/users", params: {
          user: { username: "", email: "", password: "" }
        }, headers: @header
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["message"]).not_to be_nil
      end

      it "returns user error" do
        allow_any_instance_of(::Portus::LDAP::Search).to(
          receive(:with_error_message).and_return(nil)
        )

        post "/api/v1/users", headers: @header
        expect(response).to have_http_status(:bad_request)
      end
    end

    it "with invalid JSON returns error" do
      allow_any_instance_of(::Portus::LDAP::Search).to(
        receive(:with_error_message).and_return(nil)
      )

      headers = @header.merge(
        "Content-Type": "application/json",
        "Accept":       "application/json"
      )
      post "/api/v1/users", params: '{"user":{"username"', headers: headers
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["message"]).not_to be nil
    end
  end

  describe "PUT /api/v1/users/:id" do
    context "with valid params" do
      it "updates user" do
        user = create :user
        put "/api/v1/users/#{user.id}", params: { user: user_data }, headers: @header
        expect(response).to have_http_status(:success)
        expect(User.find_by(email: user_data[:email])).not_to be_nil
      end

      it "updates user but not display_name" do
        user = create :user, display_name: "John Smith"
        put "/api/v1/users/#{user.id}",
            params: { user: user_data.except(:display_name) }, headers: @header
        expect(response).to have_http_status(:success)
        expect(User.find(user.id).display_name).to eq user.display_name
      end
    end

    context "with invalid params" do
      it "returns duplicate username errors" do
        user = create :user
        user2 = create :user
        put "/api/v1/users/#{user.id}", params: {
          user: { username: user2.username }
        }, headers: @header
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["message"]).not_to be_nil
      end

      it "returns status not found" do
        create :user
        user_id = User.maximum(:id) + 1
        put "/api/v1/users/#{user_id}", params: { user: user_data }, headers: @header
        expect(response).to have_http_status(:not_found)
      end
    end

    context "portus user" do
      it "does not allow portus user to be updated" do
        create :user, username: "portus", email: "portus@portus.com"
        portus = User.find_by(username: "portus")
        put "/api/v1/users/#{portus.id}", params: { user: user_data }, headers: @header
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "DELETE /api/v1/users/:id" do
    it "deletes user" do
      user = create :user
      delete "/api/v1/users/#{user.id}", params: nil, headers: @header
      expect(response).to have_http_status(:no_content)
      expect { User.find(user.id) }.to raise_exception(ActiveRecord::RecordNotFound)
    end

    it "returns status 404" do
      user_id = User.maximum(:id) + 1
      delete "/api/v1/users/#{user_id}", params: nil, headers: @header
      expect(response).to have_http_status(:not_found)
    end
  end

  context "POST /api/v1/users/bootstrap" do
    it "returns 400 if there is already a user available" do
      create :user
      post "/api/v1/users/bootstrap", params: { user: user_data }, headers: @header
      expect(response).to have_http_status(:bad_request)

      msg = JSON.parse(response.body)
      expect(msg["message"]).to eq(
        "you can only use this when there are no users on the system"
      )
    end

    it "returns the application token if everything went fine" do
      # Destroy all users and create the portus one. This will check that it
      # ignores the portus user when creating this new admin.
      User.destroy_all
      create(:user, username: "portus")

      expect do
        post "/api/v1/users/bootstrap", params: { user: user_data }, headers: nil
      end.to change { ApplicationToken.count }.from(0).to(1)

      expect(response).to have_http_status(:created)

      msg = JSON.parse(response.body)
      expect(msg["plain_token"]).not_to be_empty
    end

    it "makes sure that the created user is an admin" do
      User.destroy_all

      post "/api/v1/users/bootstrap", params: { user: user_data }, headers: nil
      expect(response).to have_http_status(:created)

      expect(User.first.admin?).to be_truthy
    end

    it "returns a 405 if first_user_admin was disabled" do
      APP_CONFIG["first_user_admin"] = { "enabled" => false }
      post "/api/v1/users/bootstrap", params: { user: user_data }, headers: @header
      expect(response).to have_http_status(:method_not_allowed)
    end

    it "returns a 422 when the supplied parameters have a bad format" do
      User.destroy_all
      data = user_data
      data[:email] = "bad"

      post "/api/v1/users/bootstrap", params: { user: data }, headers: nil
      expect(response).to have_http_status(:unprocessable_entity)

      msg = JSON.parse(response.body)
      expect(msg["message"]["email"].first).to eq "is invalid"
    end
  end
end
