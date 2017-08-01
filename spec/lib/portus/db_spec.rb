require "rails_helper"

describe Portus::DB do
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
