require 'rails_helper'

describe '/v2/token' do

  describe 'get token' do
    before :all do
      @password = 'this is a test'
      @user = create(:user, password: @password)
      @env = {}
     end

    describe 'as invalid user' do

      it 'denies access when the password is wrong' do
        @env['HTTP_AUTHORIZATION'] = 'Basic ' + Base64::encode64(
          "#{@user.username}:wrong password")
        get v2_token_url, { service: 'test', account: 'account', scope: 'scope' }, @env
        expect(response.status).to eq 401
      end

      it 'denies access when the user does not exist' do
        @env['HTTP_AUTHORIZATION'] = 'Basic ' + Base64::encode64(
          "caesar:password")
        get v2_token_url, { service: 'test', account: 'account', scope: 'scope' }, @env
        expect(response.status).to eq 401
      end

      it 'denies access when basic auth credentials are not defined' do
        get v2_token_url, { service: 'test', account: 'account', scope: 'scope' }
        expect(response.status).to eq 401
      end
    end

    describe 'as valid user' do
      before :all do
        @env['HTTP_AUTHORIZATION'] = 'Basic ' + Base64::encode64(
          "#{@user.username}:#{@password}")
      end

      it 'performs a request with given data' do
        get v2_token_url, { service: 'test', account: 'account', scope: 'scope' }, @env
        expect(response.status).to eq 200
      end

      it 'decoded payload should conform with params sent' do
        get v2_token_url, { service: 'test', account: 'account', scope: 'repository:foo:push' }, @env
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

end
