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
        get v2_token_url, { service: 'test', account: 'account', scope: 'repository:foo/me:push' }, invalid_auth_header
        expect(response.status).to eq 401
      end

      it 'denies access when the user does not exist' do
        get v2_token_url, { service: 'test', account: 'account', scope: 'repository:foo/me:push' }, nonexistent_auth_header
        expect(response.status).to eq 401
      end

      it 'denies access when basic auth credentials are not defined' do
        get v2_token_url, { service: 'test', account: 'account', scope: 'repository:foo/me:push' }
        expect(response.status).to eq 401
      end

    end

    context 'as valid user' do

      before do
        allow_any_instance_of(NamespacePolicy).to receive(:push?).and_return(true)
        allow_any_instance_of(NamespacePolicy).to receive(:pull?).and_return(true)
        create(:namespace, name: 'foo_namespace')
      end

      it 'performs a request with given data' do
        get v2_token_url, { service: 'test', account: 'account', scope: 'repository:foo_namespace/me:push' }, valid_auth_header
        expect(response.status).to eq 200
      end

      it 'decoded payload should conform with params sent' do
        get v2_token_url, { service: 'test', account: 'account', scope: 'repository:foo_namespace/me:push' }, valid_auth_header
        token = JSON.parse(response.body)['token']
        payload = JWT.decode(token, nil, false, { leeway: 2 })[0]
        expect(payload['sub']).to eq 'account'
        expect(payload['aud']).to eq 'test'
        expect(payload['access'][0]['type']).to eq 'repository'
        expect(payload['access'][0]['name']).to eq 'foo_namespace/me'
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

      context 'unknown scope requested' do
        before do
          get v2_token_url, { service: 'test', account: 'account', scope: 'whale:foo,bar' }, valid_auth_header
        end

        it 'respond with 401' do
          expect(response.status).to eq 401
        end
      end

    end

    context 'request push access' do
      it 'denies access to the global namespace' do
        get v2_token_url,
            { service: 'test', account: user.username, scope: 'repository:busybox:pull,push' },
            valid_auth_header
        expect(response.status).to eq 401
      end

      it 'denies access to a namespace owned by another user' do
        create(:user, username: 'qa_user')

        get v2_token_url,
            { service: 'test', account: user.username, scope: 'repository:qa_user/busybox:push' },
            valid_auth_header
        expect(response.status).to eq 401
      end

      it 'allows access to the owner' do
        get v2_token_url,
            { service: 'test', account: user.username, scope: "repository:#{user.username}/busybox:push,pull" },
            valid_auth_header
        expect(response.status).to eq 200
      end

    end

  end

end
