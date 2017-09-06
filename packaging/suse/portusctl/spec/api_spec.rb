require_relative "spec_helper"

describe ::Portusctl::API::Client do
  before :each do
    ENV["PORTUSCTL_API_USER"]   = "mssola"
    ENV["PORTUSCTL_API_SECRET"] = "hSeKZmZ2VwrWCvp_sjJf"
    ENV["PORTUSCTL_API_SERVER"] = "https://registry.mssola.cat"

    @client = ::Portusctl::API::Client.new
  end

  context "general", focus: true do
    it "" do
    end

    context "normalize_resource" do
      it "allows shortcuts for resources" do
        ::Portusctl::API::Client::RESOURCES.each_key do |k|
          (::Portusctl::API::Client::RESOURCES[k] + [k]).each do |v|
            expect(::Portusctl::API::Client.normalize_resource(v)).to eq k
          end
        end
      end

      it "returns nil on an unknown resource" do
        expect(::Portusctl::API::Client.normalize_resource("lol")).to be_nil
      end
    end
  end

  context "users" do
    context "get" do
      it "returns all the users in the system" do
        res = {}
        VCR.use_cassette("users_index_ok", record: :none) { res = @client.get("users") }

        data = JSON.parse(res)
        expect(data.size).to eq 2
      end

      it "returns the info from the required user" do
        res = {}
        VCR.use_cassette("users_show_ok", record: :none) { res = @client.get("users", 2) }

        data = JSON.parse(res)
        expect(data["id"]).to eq 2
      end

      it "errors out if the given ID could not be found" do
        res = {}
        VCR.use_cassette("users_show_fail", record: :none) { res = @client.get("users", 99) }

        expect(res).to include("Not found.")
      end
    end

    context "create" do
      it "errors out if the first argument appears to be an ID" do
        params = ["username=test", "email=test@portus.com", "password=12341234"]
        res    = @client.create("users", 99, params)

        expect(res).to eq "Unexpected ID was given!"
      end

      it "creates a user successfully" do
        res    = nil
        params = ["username=test", "email=test@portus.com", "password=12341234"]

        VCR.use_cassette("users_create_ok", record: :none) do
          res = @client.create("users", nil, params)
        end

        expect(res).to eq ["Resource 'users' created."]
      end

      it "does not create a user if it already exists" do
        res    = nil
        params = ["username=test", "email=test@portus.com", "password=12341234"]

        VCR.use_cassette("users_create_exists", record: :none) do
          res = @client.create("users", nil, params)
        end

        expect(res).to include("    - Has already been taken.")
      end
    end

    context "update" do
      it "errors out if no ID was given" do
        res = @client.update("users", nil)
        expect(res).to eq "You have to provide the ID of the user."
      end

      it "errors out if the ID does not exist" do
        res = {}
        VCR.use_cassette("users_update_fail", record: :none) { res = @client.update("users", 99) }

        expect(res).to include("Not found.")
      end

      it "updates the given user on success" do
        res = {}
        VCR.use_cassette("users_update_ok", record: :none) do
          res = @client.update("users", 2, ["email=somethingelse@email.com"])
        end

        expect(res).to eq ["Resource 'users' updated."]
      end
    end

    context "delete" do
      it "errors out if no ID was given" do
        res = @client.delete("users", nil)
        expect(res).to eq "You have to provide the ID of the user."
      end

      it "errors out if the ID does not exist" do
        res = {}
        VCR.use_cassette("users_delete_fail", record: :none) { res = @client.delete("users", 99) }

        expect(res).to include("Not found.")
      end

      it "deletes the given user on success" do
        res = {}
        VCR.use_cassette("users_delete_ok", record: :none) { res = @client.delete("users", 10) }

        expect(res).to eq ["Resource 'users' deleted."]
      end
    end
  end

  context "application tokens" do
    context "get" do
      it "errors out if no ID was given" do
        res = @client.get("application_tokens", nil)
        expect(res).to eq "You have to provide the ID of the user."
      end

      it "errors out if the ID does not exist" do
        res = {}
        VCR.use_cassette("at_get_fail", record: :none) do
          res = @client.get("application_tokens", 99)
        end

        expect(res).to include("Not found.")
      end

      it "returns a list of application tokens for the given user" do
        res = {}
        VCR.use_cassette("at_get_ok", record: :none) do
          res = @client.get("application_tokens", 2)
        end

        data = JSON.parse(res)
        expect(data.size).to eq 2
      end
    end

    context "create" do
      it "errors out if no ID was given" do
        res = @client.create("application_tokens", nil)
        expect(res).to eq "You have to provide the ID of the user."
      end

      it "errors out if the ID does not exist" do
        res = {}
        VCR.use_cassette("at_create_fail", record: :none) do
          res = @client.create("application_tokens", 99, ["application=newone"])
        end

        expect(res).to include("Not found.")
      end

      it "errors out if it's missing mandatory fields" do
        res = @client.create("application_tokens", 2)
        expect(res).to eq(["You need to set the 'application' field."])
      end

      it "returns the plain token on success" do
        res = {}
        VCR.use_cassette("at_create_ok", record: :none) do
          res = @client.create("application_tokens", 2, ["application=newone"])
        end

        expect(res).to match(/The token to be used for this/)
      end
    end

    context "delete" do
      it "errors out if no ID was given" do
        res = @client.delete("application_tokens", nil)
        expect(res).to eq "You have to provide the ID of the user."
      end

      it "errors out if the ID does not exist" do
        res = {}
        VCR.use_cassette("at_delete_fail", record: :none) do
          res = @client.delete("application_tokens", 99)
        end

        expect(res).to include("Not found.")
      end

      it "deletes the application token successfully" do
      end
    end
  end
end
