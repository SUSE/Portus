require 'rails_helper'

describe RegistryPushEvent do
  let(:registry_notification_data) do
    {
      'events' => [
        attributes_for(:raw_push_manifest_event).stringify_keys,
        attributes_for(:raw_push_layer_event).stringify_keys,
        attributes_for(:raw_pull_event).stringify_keys
      ]
    }
  end

  it 'should trigger image creation' do
    notification = RegistryNotification.new(registry_notification_data)
    event = notification.events.find {|e| e.action == 'push' }

    expect(Image).to receive(:handle_push_event) { event.data }
    event.process!
  end
end
