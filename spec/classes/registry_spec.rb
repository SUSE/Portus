require 'rails_helper'

describe Registry do
  let(:registry_server) { 'registry.test.lan' }
  let(:username) { 'flavio' }
  let(:password) { 'this is a test' }

  it 'handle ssl' do
    begin
      VCR.turned_off do
        WebMock.disable_net_connect!
        s = stub_request(:get, "https://#{registry_server}/v2/")
        registry = Registry.new(registry_server)
        registry.get_request('')
        expect(s).to have_been_requested
      end
    ensure
      WebMock.allow_net_connect!
    end
  end

  it 'fails if the registry has authentication enabled and no credentials are set' do
    path = ''
    registry = Registry.new(registry_server, false)
    VCR.use_cassette('registry/missing_credentials', record: :none) do
      expect do
        registry.get_request(path)
      end.to raise_error(Registry::CredentialsMissingError)
    end
  end

  context 'authenticating with Registry server' do
    let(:path) { '' }

    it 'can obtain an authentication token' do
      registry = Registry.new(
        registry_server,
        false,
        username,
        password)

      VCR.use_cassette('registry/successful_authentication', record: :none) do
        res = registry.get_request(path)
        expect(res).to be_a(Net::HTTPOK)
      end
    end

    it 'raise an exception when the user credentials are wrong' do
      registry = Registry.new(
        registry_server,
        false,
        username,
        'wrong password')

      VCR.use_cassette('registry/wrong_authentication', record: :none) do
        expect do
          registry.get_request(path)
        end.to raise_error(Registry::AuthorizationError)
      end
    end
  end

  context 'fetching Image manifest' do
    let(:repository) { 'foo/busybox' }
    let(:tag) { '1.0.0' }

    it 'authenticates and fetches the image manifest' do
      VCR.use_cassette('registry/get_image_manifest', record: :none) do
        registry = Registry.new(
          registry_server,
          false,
          username,
          password)

        manifest = registry.manifest(repository, tag)
        expect(manifest['name']).to eq(repository)
        expect(manifest['tag']).to eq(tag)
      end
    end

    it 'fails if the image is not found' do
      VCR.use_cassette('registry/get_missing_image_manifest', record: :none) do
        registry = Registry.new(
          registry_server,
          false,
          username,
          password)

        expect do
          registry.manifest(repository, '2.0.0')
        end.to raise_error(Registry::ManifestNotFoundError)
      end
    end
  end
end
