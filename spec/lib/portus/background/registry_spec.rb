# frozen_string_literal: true

require "rails_helper"
require "portus/background/registry"

describe ::Portus::Background::Registry do
  describe "#sleep_value" do
    it "returns always 2" do
      expect(subject.sleep_value).to eq 2
    end
  end

  describe "#work?" do
    it "always returns true" do
      expect(subject.work?).to be_truthy
    end
  end

  describe "#execute!" do
    let(:delete)    { ::Portus::Fixtures::RegistryEvent::DELETE.dup }
    let(:version23) { ::Portus::Fixtures::RegistryEvent::VERSION23.dup }

    it "calls RegistryEvent.handle! with the given events" do
      data = '{ "key": "value" }'.to_json
      RegistryEvent.create!(event_id: 1, data: data, status: RegistryEvent.statuses[:fresh])

      count = 0
      parsed = JSON.parse(data)
      allow(RegistryEvent).to receive(:handle!).with(parsed) { count += 1 }
      subject.execute!
      expect(count).to eq 1
    end

    it "does nothing if no events happened" do
      RegistryEvent.create!(event_id: 1, status: RegistryEvent.statuses[:done])

      count = 0
      allow(RegistryEvent).to receive(:handle!) { count += 1 }
      subject.execute!
      expect(count).to eq 0
    end

    it "performs well in an overall example" do
      data = { "events" => [delete, version23] }

      # All notifications are properly registered.
      ::Portus::RegistryNotification.process!(data)
      expect(RegistryEvent.count).to eq 2
      expect(RegistryEvent.all.all? { |e| e.status == "fresh" }).to be_truthy

      # And finally it processes the notifications.
      expect(Webhook).to receive(:handle_delete_event).with(delete)
      expect(Repository).to receive(:handle_delete_event).with(delete)
      expect(Webhook).to receive(:handle_push_event).with(version23)
      expect(Repository).to receive(:handle_push_event).with(version23)
      subject.execute!

      expect(RegistryEvent.all.all? { |e| e.status == "done" }).to be_truthy
    end
  end

  describe "#enabled?" do
    it "returns true when enabled" do
      APP_CONFIG["background"]["registry"] = { "enabled" => true }
      expect(subject.enabled?).to be_truthy
    end

    it "returns false when not enabled" do
      APP_CONFIG["background"]["registry"] = { "enabled" => false }
      expect(subject.enabled?).to be_falsey
    end
  end

  describe "#disable?" do
    it "always returns false" do
      expect(subject.disable?).to be_falsey
    end
  end

  describe "#to_s" do
    it "works" do
      expect(subject.to_s).to eq "Registry events"
    end
  end
end
