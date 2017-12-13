# frozen_string_literal: true

require "rails_helper"

describe Portus::DeprecationError do
  subject(:error) { described_class.new(message) }

  let(:message) { "example" }

  context "#to_s" do
    subject { error.to_s }

    it "prefixes the message with [DEPRECATED]" do
      is_expected.to eq "[DEPRECATED] #{message}"
    end
  end
end
