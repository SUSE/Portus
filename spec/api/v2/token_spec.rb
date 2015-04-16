require 'rails_helper'

describe '/v2/token' do

  describe 'get token' do

    let(:auth_mech) { ActionController::HttpAuthentication::Basic }
    let(:password) { 'this is a test' }
    let(:user) { create(:user, password: password) }

    let(:valid_auth_header) do
      { 'HTTP_AUTHORIZATION' => auth_mech.encode_credentials(user.username, password) }
    end

    let(:invalid_auth_header) do
      { 'HTTP_AUTHORIZATION' => auth_mech.encode_credentials(user.username, 'wrong_password') }
    end

    let(:nonexistent_auth_header) do
      { 'HTTP_AUTHORIZATION' => auth_mech.encode_credentials('caesar', 'password') }
    end

    context 'as invalid user' do

      it 'denies access when the password is wrong' do
        get v2_token_url, { service: 'test', account: 'account', scope: 'repo:foo:push' }, invalid_auth_header
        expect(response.status).to eq 401
      end

      it 'denies access when the user does not exist' do
        get v2_token_url, { service: 'test', account: 'account', scope: 'repo:foo:push' }, nonexistent_auth_header
        expect(response.status).to eq 401
      end

      it 'denies access when basic auth credentials are not defined' do
        get v2_token_url, { service: 'test', account: 'account', scope: 'repo:foo:push' }
        expect(response.status).to eq 401
      end

    end

    context 'as valid user' do

      it 'performs a request with given data' do
        get v2_token_url, { service: 'test', account: 'account', scope: 'repo:foo:push' }, valid_auth_header
        expect(response.status).to eq 200
      end

      it 'decoded payload should conform with params sent' do
        get v2_token_url, { service: 'test', account: 'account', scope: 'repository:foo:push' }, valid_auth_header
        token = JSON.parse(response.body)['token']
        payload = JWT.decode(token, nil, false, { leeway: 2 })[0]
        expect(payload['sub']).to eq 'account'
        expect(payload['aud']).to eq 'test'
        expect(payload['access'][0]['type']).to eq 'repository'
        expect(payload['access'][0]['name']).to eq 'foo'
        expect(payload['access'][0]['actions'][0]).to eq 'push'
      end

      context 'no scope requested' do

        before do
          get v2_token_url, { service: 'test', account: 'account' }, valid_auth_header
        end

        it 'respond with 200' do
          expect(response.status).to eq 200
        end

        it 'decoded payload should not contain access key' do
          token = JSON.parse(response.body)['token']
          payload = JWT.decode(token, nil, false, { leeway: 2 })[0]
          expect(payload).to_not have_key('access')
        end

      end

    end

  end

end
