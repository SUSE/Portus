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

  describe "wait_until" do
    before do
      # Avoid warning when changing constant value
      ::Portus::DB.send(:remove_const, "WAIT_TIMEOUT")
      ::Portus::DB.send(:remove_const, "WAIT_INTERVAL")
      # Optimizes duration of the tests
      ::Portus::DB::WAIT_TIMEOUT  = 1
      ::Portus::DB::WAIT_INTERVAL = 1
    end

    it "doesn't the given block if status is reached right away" do
      described_class.wait_until(:ready) do |_|
        raise "block should not be called"
      end
    end

    it "calls the given block with current status until it reaches the expected status" do
      allow(::Portus::DB).to receive(:migrations?).and_return(false, true)

      described_class.wait_until(:ready) do |status|
        expect(status).to eq(:empty)
      end
    end

    it "raises an exception if timeout has been reached" do
      error = ::Portus::DB::TimeoutReachedError
      expect { described_class.wait_until(:inexistent) }.to raise_error(error)
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

  describe "bundle" do
    it "returns 'bundle' if the executable exists" do
      expect(described_class.bundle).to eq "bundle"
    end
  end
end
