require "rails_helper"

describe Portus::DeprecationError do
  let(:message) { "example" }
  subject(:error) { described_class.new(message) }

  context "#to_s" do
    subject { error.to_s }
    it "prefixes the message with [DEPRECATED]" do
      is_expected.to eq "[DEPRECATED] #{message}"
    end
  end
end
