require "rails_helper"

describe RegistryPushEvent do
  let(:registry_notification_data) do
    {
      "events" => [
        build(:raw_push_manifest_event).to_test_hash,
        build(:raw_push_layer_event).to_test_hash,
        build(:raw_pull_event).to_test_hash
      ]
    }
  end

  it "should trigger image creation" do
    notification = RegistryNotification.new(registry_notification_data)
    event = notification.events.find { |e| e.action == "push" }

    expect(Repository).to receive(:handle_push_event) { event.data }
    event.process!
  end
end
