# frozen_string_literal: true

require "rails_helper"

describe Portus::DB do
  describe "ping" do
    it "returns :ready on the usual case" do
      expect(described_class.ping).to eq :ready
    end

    it "returns :empty if the DB is still initializing" do
      allow(::Portus::DB).to receive(:migrations?).and_return(false)
      expect(described_class.ping).to eq :empty
    end

    it "returns :missing if the DB is missing" do
      allow(::Portus::DB).to receive(:migrations?).and_raise(ActiveRecord::NoDatabaseError, "a")
      expect(described_class.ping).to eq :missing
    end

    it "returns :down if the DB is down" do
      allow(::Portus::DB).to receive(:migrations?).and_raise(Mysql2::Error, "a")
      expect(described_class.ping).to eq :down
    end
  end

  describe "mysql?" do
    before do
      ENV["PORTUS_DB_ADAPTER"] = nil
    end

    after do
      ENV["PORTUS_DB_ADAPTER"] = CONFIGURED_DB_ADAPTER
    end

    it "returns true if the adapter is mysql" do
      ENV["PORTUS_DB_ADAPTER"] = "mysql2"

      expect(described_class).to be_mysql
    end

    it "returns true if no adapter has been configured" do
      expect(described_class).to be_mysql
    end

    it "returns false if postgresql has been configured instead" do
      ENV["PORTUS_DB_ADAPTER"] = "postgresql"
      expect(described_class).not_to be_mysql
    end
  end
end
