require 'rails_helper'

describe '/v2/token' do

  describe 'create' do

    let(:data) { { 'events' => [] } }

    it 'handles the notification and accepts it' do
      expect_any_instance_of(RegistryNotification).to receive(:process!)
      post v2_webhooks_events_url,
        data.to_json,
        { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(response).to be_success
    end

  end

end
