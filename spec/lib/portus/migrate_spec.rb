require "rails_helper"

describe Portus::Migrate do
  describe "from_humanized_time" do
    it "evaluates as minutes if it's an integer" do
      val = Portus::Migrate.from_humanized_time(3, 2)
      expect(val).to eq 3.minutes
    end

    it "returns as minutes if it's a string of an integer" do
      val = Portus::Migrate.from_humanized_time("3", 2)
      expect(val).to eq 3.minutes
    end

    it "returns the default on error" do
      val = Portus::Migrate.from_humanized_time(/asd/, 2)
      expect(val).to eq 2.minutes
      val = Portus::Migrate.from_humanized_time("badformat", 2)
      expect(val).to eq 2.minutes
    end

    it "evals the given expression if it comes with a similar format than the old one" do
      val = Portus::Migrate.from_humanized_time("3.minutes", 2)
      expect(val).to eq 3.minutes
      val = Portus::Migrate.from_humanized_time("3.seconds", 2)
      expect(val).to eq 3.seconds
    end
  end
end
