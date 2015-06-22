require 'rails_helper'

describe RegistryNotification do
  let(:registry_notification_data) do
    {
      'events' => [
        build(:raw_push_manifest_event).to_test_hash,
        build(:raw_push_layer_event).to_test_hash,
        build(:raw_pull_event).to_test_hash
      ]
    }
  end

  it 'filters the irrelevant events' do
    notification = RegistryNotification.new(registry_notification_data)
    expect(notification.events.size).to eq(1)
    expect(notification.events.first).to be_a(RegistryPushEvent)
  end

  it 'process all the events' do
    notification = RegistryNotification.new(registry_notification_data)
    notification.events.each { |e| expect(e).to receive(:process!) }
    notification.process!
  end
end
