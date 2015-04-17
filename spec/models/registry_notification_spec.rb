require 'rails_helper'

describe RegistryNotification do
  let(:registry_notification_data) {
    {
      'events' => [
        attributes_for(:raw_push_manifest_event),
        attributes_for(:raw_push_layer_event),
        attributes_for(:raw_pull_event),
      ]
    }
  }

  it 'filters the irrelevant events' do
    notification = RegistryNotification.new(registry_notification_data)
    expect(notification.events.size).to eq(1)
    expect(notification.events.first).to be_a(RegistryPushEvent)
  end

  it 'process all the events' do
    notification = RegistryNotification.new(registry_notification_data)
    notification.events.each { |e | expect(e).to receive(:process!) }
    notification.process!
  end
end
