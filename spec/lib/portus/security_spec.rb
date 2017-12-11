# frozen_string_literal: true

require "rails_helper"

describe ::Portus::Security do
  describe "#enabled?" do
    it "is disabled if no backend has been configured" do
      APP_CONFIG["security"] = {
        "clair" => {
          "server" => ""
        }, "zypper" => {
          "server" => ""
        }, "dummy" => {
          "server" => ""
        }
      }

      sec = described_class.new("some", "tag")
      expect(sec).not_to be_available
      expect(described_class).not_to be_enabled
    end

    it "is enabled when at least one has been configured" do
      APP_CONFIG["security"] = {
        "clair" => {
          "server" => ""
        }, "zypper" => {
          "server" => ""
        }, "dummy" => {
          "server" => "dummy"
        }
      }

      sec = described_class.new("some", "tag")
      expect(sec).to be_available
      expect(described_class).to be_enabled
    end

    it "is enabled when all has been configured" do
      APP_CONFIG["security"] = {
        "clair" => {
          "server" => "http://clair.server"
        }, "zypper" => {
          "server" => "http://some.server"
        }, "dummy" => {
          "server" => "dummy"
        }
      }

      sec = described_class.new("some", "tag")
      expect(sec).to be_available
      expect(described_class).to be_enabled
    end
  end
end
