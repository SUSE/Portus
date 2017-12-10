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

      sec = ::Portus::Security.new("some", "tag")
      expect(sec.available?).to be_falsey
      expect(::Portus::Security.enabled?).to be_falsey
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

      sec = ::Portus::Security.new("some", "tag")
      expect(sec.available?).to be_truthy
      expect(::Portus::Security.enabled?).to be_truthy
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

      sec = ::Portus::Security.new("some", "tag")
      expect(sec.available?).to be_truthy
      expect(::Portus::Security.enabled?).to be_truthy
    end
  end
end
