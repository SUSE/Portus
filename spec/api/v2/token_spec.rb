require "rails_helper"

describe "/v2/token" do

  describe "get token" do

    let(:auth_mech) { ActionController::HttpAuthentication::Basic }
    let(:password) { "this is a test" }
    let(:user) { create(:user, password: password) }
    let(:registry) { create(:registry) }

    let(:valid_auth_header) do
      { "HTTP_AUTHORIZATION" => auth_mech.encode_credentials(user.username, password) }
    end

    let(:invalid_auth_header) do
      { "HTTP_AUTHORIZATION" => auth_mech.encode_credentials(user.username, "wrong_password") }
    end

    let(:nonexistent_auth_header) do
      { "HTTP_AUTHORIZATION" => auth_mech.encode_credentials("caesar", "password") }
    end

    context "as invalid user" do
      let(:valid_request) do
        {
          service: registry.hostname,
          account: "account",
          scope:   "repository:foo_namespace/me:push"
        }
      end

      it "denies access when the password is wrong" do
        get v2_token_url,
          { service: registry.hostname, account: "account", scope: "repository:foo/me:push" },
          invalid_auth_header

        expect(response.status).to eq 401
      end

      it "denies access when the user does not exist" do
        get v2_token_url,
          { service: registry.hostname, account: "account", scope: "repository:foo/me:push" },
          nonexistent_auth_header

        expect(response.status).to eq 401
      end

      it "denies access when basic auth credentials are not defined" do
        get v2_token_url,
          service: registry.hostname, account: "account", scope: "repository:foo/me:push"
        expect(response.status).to eq 401
      end

      it "denies access to a disabled user" do
        user.update_attributes(enabled: false)
        get v2_token_url, valid_request, valid_auth_header
        expect(response.status).to eq 401
      end
    end

    context "as another user" do
      let(:another) { create(:user, password: password) }

      it "does not allow to pull a private namespace from another team" do
        # It works for the regular user
        get v2_token_url,
          { service: registry.hostname, account: user.username,
            scope: "repository:#{user.username}/busybox:push,pull" },
          "HTTP_AUTHORIZATION" => auth_mech.encode_credentials(user.username, password)

        expect(response.status).to eq 200

        # But not for another
        get v2_token_url,
          { service: registry.hostname, account: another.username,
            scope: "repository:#{user.username}/busybox:push,pull" },
          "HTTP_AUTHORIZATION" => auth_mech.encode_credentials(another.username, password)

        expect(response.status).to eq 401
      end
    end

    context "as valid user" do
      let(:valid_request) do
        {
          service: registry.hostname,
          account: "account",
          scope:   "repository:foo_namespace/me:push"
        }
      end

      before do
        allow_any_instance_of(NamespacePolicy).to receive(:push?).and_return(true)
        allow_any_instance_of(NamespacePolicy).to receive(:pull?).and_return(true)
        create(:namespace, name: "foo_namespace", registry: registry)
      end

      it "performs a request with given data" do
        get v2_token_url, valid_request, valid_auth_header
        expect(response.status).to eq 200
      end

      it "decoded payload should conform with params sent" do
        get v2_token_url, valid_request, valid_auth_header
        token = JSON.parse(response.body)["token"]
        payload = JWT.decode(token, nil, false, leeway: 2)[0]
        expect(payload["sub"]).to eq "account"
        expect(payload["aud"]).to eq registry.hostname
        expect(payload["access"][0]["type"]).to eq "repository"
        expect(payload["access"][0]["name"]).to eq "foo_namespace/me"
        expect(payload["access"][0]["actions"][0]).to eq "push"
      end

      context "no scope requested" do
        before do
          get v2_token_url, { service: registry.hostname, account: "account" }, valid_auth_header
        end

        it "respond with 200" do
          expect(response.status).to eq 200
        end

        it "decoded payload should not contain access key" do
          token = JSON.parse(response.body)["token"]
          payload = JWT.decode(token, nil, false, leeway: 2)[0]
          expect(payload).to_not have_key("access")
        end

      end

      context "unknown scope requested" do
        before do
          get v2_token_url,
            { service: registry.hostname, account: "account", scope: "whale:foo,bar" },
            valid_auth_header
        end

        it "respond with 401" do
          expect(response.status).to eq 401
        end
      end

      context "repository scope" do
        it "delegates authentication to the Namespace policy" do
          personal_namespace = Namespace.find_by(name: user.username)
          expect_any_instance_of(Api::V2::TokensController).to receive(:authorize)
            .with(personal_namespace, :push?)
          expect_any_instance_of(Api::V2::TokensController).to receive(:authorize)
            .with(personal_namespace, :pull?)

          get v2_token_url,
            {
              service: registry.hostname,
              account: user.username,
              scope:   "repository:#{user.username}/busybox:push,pull"
            },
            valid_auth_header
        end

        it "allows to pull an image in which this user is just a viewer"  do
          # Quick way to force a "viewer" policy.
          allow_any_instance_of(NamespacePolicy).to receive(:push?).and_return(false)
          allow_any_instance_of(NamespacePolicy).to receive(:pull?).and_return(true)

          get v2_token_url,
            { service: registry.hostname, account: user.username,
              scope: "repository:#{user.username}/busybox:push,pull" },
            valid_auth_header

          expect(response.status).to eq 200

          # And check that the only authorized scope is "pull"
          token = JSON.parse(response.body)["token"]
          payload = JWT.decode(token, nil, false, leeway: 2)[0]
          expect(payload["access"][0]["name"]).to eq "#{user.username}/busybox"
          expect(payload["access"][0]["actions"]).to match_array ["pull"]
        end
      end

      context "registry scope" do
        let(:valid_request) do
          {
            service: registry.hostname,
            account: "portus",
            scope:   "registry:catalog:*"
          }
        end

        let(:valid_portus_auth_header) do
          {
            "HTTP_AUTHORIZATION" =>
              auth_mech.encode_credentials("portus", Rails.application.secrets.portus_password)
          }
        end

        before do
          User.create!(
            username: "portus",
            password: Rails.application.secrets.portus_password,
            email:    "portus@portus.com",
            admin:    true
          )
        end

        it "allows portus to access the Catalog API" do
          get v2_token_url, valid_request, valid_portus_auth_header
          expect(response.status).to eq 200

          token = JSON.parse(response.body)["token"]
          payload = JWT.decode(token, nil, false, leeway: 2)[0]
          expect(payload["sub"]).to eq "portus"
          expect(payload["aud"]).to eq registry.hostname
          expect(payload["access"][0]["type"]).to eq "registry"
          expect(payload["access"][0]["name"]).to eq "catalog"
          expect(payload["access"][0]["actions"][0]).to eq "*"
        end

        it "forbids unhandled methods from the registry type" do
          wr = valid_request
          wr[:scope] = "registry:catalog:lala"
          get v2_token_url, wr, valid_portus_auth_header
          expect(response.status).to eq 401
        end
      end

      context "unknown scope" do
        it "denies access" do
          get v2_token_url,
              {
                service: registry.hostname,
                account: user.username,
                scope:   "repository:busybox:fork"
              },
              valid_auth_header
          expect(response.status).to eq 401
        end
      end

      context "unknown type" do
        it "denies access" do
          get v2_token_url,
              { service: registry.hostname, account: user.username, scope: "lala:busybox:fork" },
              valid_auth_header
          expect(response.status).to eq 401
        end
      end

      context "unkwnow registry" do
        context "no scope requested" do
          it "respond with 401" do
            get v2_token_url, { service: "does not exist", account: "account" }, valid_auth_header
            expect(response.status).to eq 401
          end
        end

        context "reposity scope" do
          it "it responde with 401" do
            # force creation of the namespace
            namespace = create(:namespace,
                               team:     Team.find_by(name: user.username),
                               registry: registry)
            wrong_registry = create(:registry)

            get(
              v2_token_url,
              {
                service: wrong_registry.hostname,
                account: user.username,
                scope:   "repository:#{namespace.name}/busybox:push,pull"
              },
              valid_auth_header
            )
            expect(response.status).to eq(401)
          end
        end
      end

    end

  end

end
