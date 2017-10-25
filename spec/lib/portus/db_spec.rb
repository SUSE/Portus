require "rails_helper"

describe Portus::DB do
  describe "ping" do
    it "returns :ready on the usual case" do
      expect(Portus::DB.ping).to eq :ready
    end

    it "returns :empty if the DB is still initializing" do
      allow(::Portus::DB).to receive(:migrations?).and_return(false)
      expect(Portus::DB.ping).to eq :empty
    end

    it "returns :missing if the DB is missing" do
      allow(::Portus::DB).to receive(:migrations?).and_raise(ActiveRecord::NoDatabaseError, "a")
      expect(Portus::DB.ping).to eq :missing
    end

    it "returns :down if the DB is down" do
      allow(::Portus::DB).to receive(:migrations?).and_raise(Mysql2::Error, "a")
      expect(Portus::DB.ping).to eq :down
    end
  end

  describe "mysql?" do
    before :each do
      ENV["PORTUS_DB_ADAPTER"] = nil
    end

    after :each do
      ENV["PORTUS_DB_ADAPTER"] = nil
    end

    it "returns true if the adapter is mysql" do
      ENV["PORTUS_DB_ADAPTER"] = "mysql2"

      expect(Portus::DB.mysql?).to be_truthy
    end

    it "returns true if no adapter has been configured" do
      expect(Portus::DB.mysql?).to be_truthy
    end

    it "returns false if postgresql has been configured instead" do
      ENV["PORTUS_DB_ADAPTER"] = "postgresql"
      expect(Portus::DB.mysql?).to be_falsey
    end
  end
end
