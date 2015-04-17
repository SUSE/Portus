require 'rails_helper'

RSpec.describe RegistryNotification do
  describe 'handling registry events' do
    let(:relevant_push_event) {
      {
        'action' => 'push',
        'target' => {
          'repository' => 'foo',
          'url' =>  'http://registry.test.lan/v2/foo/manifests/latest'
        }
      }
    }

    let(:registry_notification_data) {
      {
        'events' => [
          relevant_push_event,
          {
            'action' => 'push',
            'target' => {
              'repository' => 'foo',
              'url' =>  'http://registry.test.lan/v2/foo/layer/123'
            }
          },
          {
            'action' => 'pull'
          }
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

    context 'push event' do
      it 'should trigger image creation' do
        notification = RegistryNotification.new(registry_notification_data)
        event = notification.events.find { |e| e.action == 'push' }

        expect(Image).to receive(:handle_push_event) { event.data }
        event.process!
      end
    end
  end
end
