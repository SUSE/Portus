# frozen_string_literal: true

require "rails_helper"

describe Portus::RegistryNotification do
  let(:body)      { ::Portus::Fixtures::RegistryEvent::BODY.dup }
  let(:relevant)  { ::Portus::Fixtures::RegistryEvent::RELEVANT.dup }
  let(:delete)    { ::Portus::Fixtures::RegistryEvent::DELETE.dup }
  let(:version23) { ::Portus::Fixtures::RegistryEvent::VERSION23.dup }
  let(:pull)      { ::Portus::Fixtures::RegistryEvent::PULL.dup }

  it "processes all the relevant events" do
    evaluated_events = [relevant, delete, version23, pull]
    evaluated_events.each { |e| body["events"] << e }

    described_class.process!(body)

    events = RegistryEvent.order(:event_id)
    expect(events.size).to eq 4
    events.each_with_index do |e, idx|
      data = JSON.parse(e.data)

      expect(data).to eq evaluated_events[idx]
      expect(e.status).to eq "fresh"
    end
  end

  it "does not process the same event multiple times" do
    body["events"] = [version23]
    expect { described_class.process!(body) }.to(change { RegistryEvent.count }.from(0).to(1))

    body["events"] = [version23]
    expect { described_class.process!(body) }.to_not(change { RegistryEvent.count })
  end
end
