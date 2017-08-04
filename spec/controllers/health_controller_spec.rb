require "rails_helper"

# Helper for the tests on the database that simply calls :health and returns the
# JSON message for the database component.
def db_helper_msg
  get :health

  data = JSON.parse(response.body)
  data["database"]["msg"]
end

RSpec.describe HealthController, type: :controller do
  describe "GET /_ping" do
    it "gets an 200 response" do
      get :index
      expect(response.status).to eq 200
    end
  end

  describe "GET /_health" do
    describe "Basic functionality" do
      it "has DB but no registry" do
        get :health
        expect(response.status).to eq 503
      end

      it "has both the DB and the registry" do
        create(:registry, hostname: "registry.mssola.cat", use_ssl: true)

        VCR.use_cassette("health/ok", record: :none) do
          get :health
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
      before :each do
        APP_CONFIG["security"]["clair"]["server"] = "http://registry.mssola.cat"
        APP_CONFIG["security"]["clair"]["health_port"] = "6061"
        create(:registry, hostname: "registry.mssola.cat", use_ssl: true)
      end

      it "handles a proper 200 response" do
        VCR.use_cassette("health/clair-ok", record: :none) do
          get :health
          expect(response.status).to eq 200
        end
      end

      it "works even if the server contains another port" do
        APP_CONFIG["security"]["clair"]["server"] = "http://registry.mssola.cat:6060"

        VCR.use_cassette("health/clair-ok", record: :none) do
          get :health
          expect(response.status).to eq 200
        end
      end

      it "handles errors as well" do
        # Forcing a 404 from Clair.
        expect(::Portus::HealthChecks::Clair).to receive(:health_endpoint).and_raise(SocketError)

        VCR.use_cassette("health/clair-bad", record: :none) do
          get :health
          expect(response.status).to eq 503
        end
      end
    end
  end
end
