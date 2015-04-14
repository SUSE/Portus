require 'rails_helper'

describe '/v2/token' do

  describe 'get token' do

    it 'performs a request with given data' do
      get v2_token_url, { service: 'test', account: 'account', scope: 'scope' }
      expect(response.status).to eq 200
    end

  end

end
