# frozen_string_literal: true

require "rails_helper"

describe Portus::Migrate do
  describe "from_humanized_time" do
    it "evaluates as minutes if it's an integer" do
      val = described_class.from_humanized_time(3, 2)
      expect(val).to eq 3.minutes
    end

    it "returns as minutes if it's a string of an integer" do
      val = described_class.from_humanized_time("3", 2)
      expect(val).to eq 3.minutes
    end

    it "returns the default on error" do
      val = described_class.from_humanized_time(/asd/, 2)
      expect(val).to eq 2.minutes
      val = described_class.from_humanized_time("badformat", 2)
      expect(val).to eq 2.minutes
    end

    it "raises a deprecation error when an expression is given" do
      expect { described_class.from_humanized_time("3.minutes", 2) }.to \
        raise_error(Portus::DeprecationError)
      expect { described_class.from_humanized_time("3.seconds", 2) }.to \
        raise_error(Portus::DeprecationError)
    end
  end

  describe "registry_config" do
    before do
      @registry = APP_CONFIG["registry"]
    end

    after do
      APP_CONFIG["registry"] = @registry
      APP_CONFIG["jwt_expiration_time"] = nil
    end

    it "returns a value depending of the format" do
      expect(described_class.registry_config("jwt_expiration_time")).not_to be_nil

      APP_CONFIG["registry"] = nil
      APP_CONFIG["jwt_expiration_time"] = { "value" => 5 }

      expect { described_class.registry_config("jwt_expiration_time") }.to \
        raise_error(Portus::DeprecationError)
    end
  end
end
