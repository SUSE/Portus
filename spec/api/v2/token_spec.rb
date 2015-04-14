require 'rails_helper'

describe '/v2/token' do

  describe 'get token' do

    it 'performs a request with given data' do
      get v2_token_url, { service: 'test', account: 'account', scope: 'scope' }
      expect(response.status).to eq 200
    end

    it 'decoded payload should conform with params sent' do
      get v2_token_url, { service: 'test', account: 'account', scope: 'repository:foo:push' }
      token = JSON.parse(response.body)['token']
      payload = JWT.decode(token, nil, false, { leeway: 2 })[0]
      expect(payload['sub']).to eq 'account'
      expect(payload['aud']).to eq 'test'
      expect(payload['access'][0]['type']).to eq 'repository'
      expect(payload['access'][0]['name']).to eq 'foo'
      expect(payload['access'][0]['actions'][0]).to eq 'push'
    end

  end

end
