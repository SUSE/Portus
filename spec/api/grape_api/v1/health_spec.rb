# frozen_string_literal: true

require "rails_helper"
require "ostruct"
require "portus/registry_client"

# Helper for the tests on the database that simply calls :health and returns the
# JSON message for the database component.
def db_helper_msg
  get "/api/v1/health"

  data = JSON.parse(response.body)
  data["database"]["msg"]
end

describe API::V1::Health, type: :request do
  describe "GET /_ping" do
    it "gets an 200 response" do
      get "/api/v1/_ping"
      expect(response.status).to eq 200
    end
  end

  context "GET /health" do
    describe "Basic functionality" do
      it "has DB but no registry" do
        get "/api/v1/health"
        expect(response.status).to eq 503
      end

      it "reached a RequestError when trying to connect to the registry" do
        create(:registry, hostname: "whatever", use_ssl: false)

        allow_any_instance_of(::Portus::RegistryClient).to receive(:reachable?)
          .and_raise(::Portus::RequestError, exception: Net::ReadTimeout, message: "something")

        get "/api/v1/health"
        expect(response.status).to eq 503
        data = JSON.parse(response.body)
        expect(data["registry"]["msg"]).to eq "Class: something"
      end

      it "has both the DB and the registry" do
        create(:registry, hostname: "registry.mssola.cat", use_ssl: true)

        VCR.use_cassette("health/ok", record: :none) do
          get "/api/v1/health"
          expect(response.status).to eq 200
        end
      end
    end

    describe "Database" do
      it "returns ready in the usual case" do
        expect(db_helper_msg).to eq "database is up-to-date"
      end

      it "returns empty when the database is initializing" do
        allow(::Portus::DB).to receive(:migrations?).and_return(false)
        expect(db_helper_msg).to eq "database is initializing"
      end

      it "returns missing when the database does not exist" do
        allow(::Portus::DB).to receive(:migrations?).and_raise(ActiveRecord::NoDatabaseError, "a")
        expect(db_helper_msg).to eq "database has not been created"
      end

      it "returns down if the DB is down" do
        allow(::Portus::DB).to receive(:migrations?).and_raise(Mysql2::Error, "a")
        expect(db_helper_msg).to eq "cannot connect to database"
      end

      it "returns unknown for unexpected errors" do
        allow(::Portus::DB).to receive(:migrations?).and_raise(StandardError, "a")
        expect(db_helper_msg).to eq "unknown error"
      end
    end

    describe "Clair enabled" do
      before do
        APP_CONFIG["security"]["clair"]["server"] = "http://registry.mssola.cat"
        APP_CONFIG["security"]["clair"]["health_port"] = "6061"
        create(:registry, hostname: "registry.mssola.cat", use_ssl: true)
      end

      it "handles a proper 200 response" do
        VCR.use_cassette("health/clair-ok", record: :none) do
          get "/api/v1/health"
          expect(response.status).to eq 200
        end
      end

      it "works even if the server contains another port" do
        APP_CONFIG["security"]["clair"]["server"] = "http://registry.mssola.cat:6060"

        VCR.use_cassette("health/clair-ok", record: :none) do
          get "/api/v1/health"
          expect(response.status).to eq 200
        end
      end

      it "corrects when the protocol was not specified" do
        APP_CONFIG["security"]["clair"]["server"] = "registry.mssola.cat"

        VCR.use_cassette("health/clair-ok", record: :none) do
          get "/api/v1/health"
          expect(response.status).to eq 200
        end
      end

      it "handles errors as well" do
        # Forcing a 404 from Clair.
        expect(::Portus::HealthChecks::Clair).to receive(:health_endpoint).and_raise(SocketError)

        VCR.use_cassette("health/clair-bad", record: :none) do
          get "/api/v1/health"
          expect(response.status).to eq 503
        end
      end
    end

    describe "LDAP support" do
      before do
        # NOTE: we are mocking the registry because this has already been tested
        # above. Moreover LDAP requests don't happen under HTTP, so VCR will
        # ignore these requests. Hence, we also have to mock LDAP requests on
        # each test. Proper tests are provided as integration tests.
        allow_any_instance_of(::Portus::RegistryClient).to(
          receive(:reachable?).and_return(true)
        )
        create(:registry, hostname: "registry.mssola.cat", use_ssl: true)
      end

      it "is disabled" do
        get "/api/v1/health"
        expect(response.status).to eq 200

        data = JSON.parse(response.body)
        expect(data.key?("ldap")).to be_falsey
      end

      it "server is not reachable" do
        APP_CONFIG["ldap"]["enabled"] = true

        allow_any_instance_of(Net::LDAP).to(
          receive(:bind)
            .and_raise(Net::LDAP::Error, "error")
        )

        get "/api/v1/health"
        expect(response.status).to eq 503

        data = JSON.parse(response.body)
        expect(data["ldap"]["msg"]).to eq "error"
      end

      it "is ok" do
        APP_CONFIG["ldap"]["enabled"] = true
        APP_CONFIG["ldap"]["hostname"] = "ldap"
        APP_CONFIG["ldap"]["authentication"] = {
          "enabled"  => true,
          "bind_dn"  => "cn=admin,dc=example,dc=org",
          "password" => "admin"
        }

        allow_any_instance_of(Net::LDAP).to(receive(:bind).and_return(true))

        get "/api/v1/health"
        expect(response.status).to eq 200

        data = JSON.parse(response.body)
        expect(data["ldap"]["msg"]).to eq "LDAP server is reachable"
      end

      it "fails on authentication error" do
        APP_CONFIG["ldap"]["enabled"] = true
        APP_CONFIG["ldap"]["hostname"] = "ldap"
        APP_CONFIG["ldap"]["authentication"] = {
          "enabled"  => true,
          "bind_dn"  => "cn=admin,dc=example,dc=org",
          "password" => "badpassword"
        }

        allow_any_instance_of(Net::LDAP).to(
          receive(:bind).and_return(false)
        )
        allow_any_instance_of(Net::LDAP).to(
          receive(:get_operation_result)
            .and_return(OpenStruct.new(message: "Invalid Credentials", code: 49))
        )

        get "/api/v1/health"
        expect(response.status).to eq 503

        data = JSON.parse(response.body)
        expect(data["ldap"]["msg"]).to eq "Invalid Credentials (code 49)"
      end
    end
  end
end
