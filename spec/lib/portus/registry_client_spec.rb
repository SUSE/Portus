# frozen_string_literal: true

require "rails_helper"

# The RegistryClient defaults to the "portus" user if no credentials were
# given. This mock class serves to test a class that misses the credentials.
class RegistryClientMissingCredentials < Portus::RegistryClient
  def initialize(host)
    super(host)
    @username = nil
    @password = nil
  end
end

# This class mocks the `perform_request` by returning whatever has been request
# in the initializer.
class RegistryPerformRequest < Portus::RegistryClient
  def initialize(status)
    @status = status
  end

  def perform_request(_endpoint, _verb, _authentication)
    # We don't care about the given parameters.

    return nil if @status.nil?

    OpenStruct.new(code: @status, header: { "Docker-Distribution-Api-Version" => "registry/2.0" })
  end
end

# This class is used to access directly to the "fetch_link" protected method.
class RegistryClientFetchLink < Portus::RegistryClient
  def initialize; end

  def fetch_link_test(header)
    fetch_link(header)
  end
end

describe Portus::RegistryClient do
  let(:registry_server) { "registry.test.lan" }
  let(:username) { "flavio" }
  let(:password) { "this is a test" }

  it "handle ssl" do
    VCR.turned_off do
      WebMock.disable_net_connect!
      s = stub_request(:get, "https://#{registry_server}/v2/")
      registry = described_class.new(registry_server, true)
      registry.perform_request("")
      expect(s).to have_been_requested
    end
  ensure
    WebMock.allow_net_connect!
  end

  it "fails if the registry has authentication enabled and no credentials are set" do
    VCR.turn_on!
    path = ""
    registry = RegistryClientMissingCredentials.new(registry_server)
    VCR.use_cassette("registry/missing_credentials", record: :none) do
      expect do
        registry.perform_request(path)
      end.to raise_error(Portus::RegistryClient::CredentialsMissingError)
    end
  end

  context "authenticating with Registry server" do
    let(:path) { "" }

    it "can obtain an authentication token" do
      registry = described_class.new(
        registry_server,
        false,
        username,
        password
      )

      VCR.use_cassette("registry/successful_authentication", record: :none) do
        res = registry.perform_request(path)
        expect(res).to be_a(Net::HTTPOK)
      end
    end

    it "raise an exception when the user credentials are wrong" do
      registry = described_class.new(
        registry_server,
        false,
        username,
        "wrong password"
      )

      VCR.use_cassette("registry/wrong_authentication", record: :none) do
        expect do
          registry.perform_request(path)
        end.to raise_error(Portus::RegistryClient::AuthorizationError)
      end
    end

    it "raises an AuthorizationError when the credentials are always wrong" do
      registry = described_class.new(
        registry_server,
        false,
        username,
        password
      )

      begin
        VCR.turned_off do
          WebMock.disable_net_connect!
          auth = "service=foo,Bearer realm=http://portus.test.lan/token"
          url  = "http://portus.test.lan/token?account=flavio&service=foo"

          stub_request(:get, "http://#{registry_server}/v2/")
            .to_return(headers: { "www-authenticate" => auth }, status: 401)

          stub_request(:get, url).to_return(status: 401)

          expect do
            registry.perform_request("")
          end.to raise_error(Portus::RegistryClient::AuthorizationError)
        end
      ensure
        WebMock.allow_net_connect!
      end
    end

    it "raises a NoBearerRealmException when the bearer realm is not found" do
      registry = described_class.new(
        registry_server,
        false,
        username,
        password
      )

      begin
        VCR.turned_off do
          WebMock.disable_net_connect!
          stub_request(:get, "http://#{registry_server}/v2/")
            .to_return(headers: { "www-authenticate" => "foo=bar" }, status: 401)

          expect do
            registry.perform_request("")
          end.to raise_error(Portus::RegistryClient::NoBearerRealmException)
        end
      ensure
        WebMock.allow_net_connect!
      end
    end

    it "raises a NoBearerRealmException when the bearer realm is not found" do
      registry = described_class.new(
        registry_server,
        false,
        username,
        password
      )

      begin
        VCR.turned_off do
          WebMock.disable_net_connect!
          stub_request(:get, "http://#{registry_server}/v2/")
            .to_return(headers: { "www-authenticate" => "foo=bar" }, status: 401)

          expect do
            registry.perform_request("")
          end.to raise_error(Portus::RegistryClient::NoBearerRealmException)
        end
      ensure
        WebMock.allow_net_connect!
      end
    end
  end

  context "is reachable or not" do
    it "returns the proper thing in all the scenarios" do
      [[nil, false], [404, false], [200, true], [401, true]].each do |cs|
        r = RegistryPerformRequest.new(cs.first)
        expect(r.reachable?).to be cs.last
      end
    end
  end

  context "fetching Image manifest" do
    let(:repository) { "foo/busybox" }
    let(:tag)        { "1.0.0" }
    let(:id)         { "3a093384ac306cbac30b67f1585e12b30ab1a899374dabc3170b9bca246f1444" }
    let(:size)       { 757_221 }
    let(:digest)     { "sha256:bbb143159af9eabdf45511fd5aab4fd2475d4c0e7fd4a5e154b98e838488e510" }

    it "authenticates and fetches the image manifest" do
      VCR.use_cassette("registry/get_image_manifest", record: :none) do
        registry = described_class.new(
          registry_server,
          false,
          username,
          password
        )

        manifest = registry.manifest(repository, tag)
        expect(manifest.id).to eq(id)
        expect(manifest.digest).to eq(digest)
        expect(manifest.size).to eq(size)
      end
    end

    it "fails if the image is not found" do
      VCR.use_cassette("registry/get_missing_image_manifest", record: :none) do
        registry = described_class.new(
          registry_server,
          false,
          username,
          password
        )

        expect do
          registry.manifest(repository, "2.0.0")
        end.to raise_error(Portus::RegistryClient::NotFoundError)
      end
    end

    it "raises an exception when the return code is different from 200 or 401" do
      registry = described_class.new(
        registry_server,
        false,
        username,
        password
      )
      tag = "2.0.0"

      begin
        VCR.turned_off do
          WebMock.disable_net_connect!
          stub_request(:get, "http://#{registry_server}/v2/#{repository}/manifests/#{tag}")
            .to_return(body: "BOOM", status: 500)

          expect do
            registry.manifest(repository, tag)
          end.to raise_error(::Portus::RegistryClient::ManifestError)
        end
      ensure
        WebMock.allow_net_connect!
      end
    end
  end

  context "fetching Catalog from registry" do
    it "returns the available catalog" do
      create(:registry)
      User.create_portus_user!

      VCR.use_cassette("registry/get_registry_catalog", record: :none) do
        registry = described_class.new(
          registry_server,
          false,
          "portus",
          Rails.application.secrets.portus_password
        )

        catalog = registry.catalog
        expect(catalog.length).to be 1
        expect(catalog[0]["name"]).to eq "busybox"
        expect(catalog[0]["tags"]).to match_array(["latest"])
      end
    end

    it "returns the available catalog even if it has more than 100 repos" do
      create(:registry)
      User.create_portus_user!

      VCR.use_cassette("registry/catalog_lots_of_repos", record: :none) do
        WebMock.disable_net_connect!
        stub_request(:get, "http://#{registry_server}/v2/busybox/tags/list?n=100")
          .to_return(body: "{\"name\": \"busybox\", \"tags\":[\"latest\"]} ", status: 200)
        (1..101).each do |i|
          stub_request(:get, "http://#{registry_server}/v2/busybox#{i}/tags/list?n=100")
            .to_return(body: "{\"name\": \"busybox#{i}\", \"tags\":[\"latest\"]} ", status: 200)
        end

        registry = described_class.new(
          registry_server,
          false,
          "portus",
          Rails.application.secrets.portus_password
        )

        catalog = registry.catalog
        expect(catalog.length).to be 102
      end
    end

    it "does not remove all repos just because one of them is failing" do
      create(:registry)
      User.create_portus_user!

      VCR.use_cassette("registry/get_registry_one_fails", record: :none) do
        registry = described_class.new(
          registry_server,
          false,
          "portus",
          Rails.application.secrets.portus_password
        )

        catalog = registry.catalog
        expect(catalog.length).to be 2
        expect(catalog[0]["name"]).to eq "busybox"
        expect(catalog[0]["tags"]).to match_array(["latest"])

        # The second repo failed at fetching tags. Thus, it will be set to nil
        # to reflect this situation.
        expect(catalog[1]["name"]).to eq "another"
        expect(catalog[1]["tags"]).to be_nil
      end
    end

    it "fails if this version of registry does not implement /v2/_catalog" do
      VCR.use_cassette("registry/get_missing_catalog_endpoint", record: :none) do
        registry = described_class.new(
          registry_server,
          false,
          username,
          password
        )

        expect do
          registry.catalog
        end.to raise_error(Portus::RegistryClient::NotFoundError)
      end
    end

    it "raises an exception when the return code is different from 200 or 401" do
      registry = described_class.new(
        registry_server,
        false,
        username,
        password
      )

      begin
        VCR.turned_off do
          WebMock.disable_net_connect!
          stub_request(:get, "http://#{registry_server}/v2/_catalog?n=100")
            .to_return(body: "BOOM", status: 500)

          expect do
            registry.catalog
          end.to raise_error(::Portus::RegistryClient::RegistryError)
        end
      ensure
        WebMock.allow_net_connect!
      end
    end

    it "fetches the link from the registry properly" do
      registry = RegistryClientFetchLink.new
      expect(registry.fetch_link_test([])).to be_empty
      link = "<v2/_catalog?last=mssola%2Fbusybox89&n=100>; rel=\"next\""
      expect(registry.fetch_link_test(link)).to eq "v2/_catalog?last=mssola%2Fbusybox89&n=100"
    end

    it "returns nil for tags when an exception happened" do
      create(:registry)
      User.create_portus_user!

      allow_any_instance_of(::Portus::RegistryClient).to receive(:tags) do
        raise ::Portus::Errors::NotFoundError, "I AM ERROR"
      end

      VCR.use_cassette("registry/get_registry_catalog", record: :none) do
        registry = described_class.new(
          registry_server,
          false,
          "portus",
          Rails.application.secrets.portus_password
        )

        catalog = registry.catalog
        expect(catalog.length).to be 1
        expect(catalog[0]["name"]).to eq "busybox"
        expect(catalog[0]["tags"]).to be_nil
      end
    end
  end

  context "fetching lists from the catalog" do
    it "returns the available tags even if there are more than 100 of them" do
      create(:registry)
      User.create_portus_user!

      VCR.use_cassette("registry/catalog_lots_of_tags", record: :none) do
        registry = described_class.new(
          registry_server,
          false,
          "portus",
          Rails.application.secrets.portus_password
        )

        tags = registry.tags("busybox")
        (1..102).each_with_index { |v, idx| expect(tags[idx]).to eq v.to_s }
      end
    end
  end

  context "deleting a blob from an image" do
    it "deleting a blob that does not exist" do
      VCR.use_cassette("registry/delete_missing_blob", record: :none) do
        registry = described_class.new(
          registry_server,
          false,
          "portus",
          Rails.application.secrets.portus_password
        )

        expect do
          registry.delete("busybox",
                          "sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4")
        end.to raise_error(Portus::RegistryClient::NotFoundError, /BLOB_UNKNOWN/)
      end
    end

    it "deleting blobs is not enabled on the server" do
      VCR.use_cassette("registry/delete_disabled", record: :none) do
        registry = described_class.new(
          registry_server,
          false,
          "portus",
          Rails.application.secrets.portus_password
        )

        expect do
          registry.delete("busybox",
                          "sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4")
        end.to raise_error(Portus::RegistryClient::NotFoundError, /UNSUPPORTED/)
      end
    end

    it "allows the deletion of blobs" do
      VCR.use_cassette("registry/delete_blob", record: :none) do
        registry = described_class.new(
          registry_server,
          false,
          "portus",
          Rails.application.secrets.portus_password
        )

        sha = "sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4"
        res = registry.delete("busybox", sha)
        expect(res).to be true
      end
    end

    it "does what we expect on a Bad Request" do
      VCR.use_cassette("registry/invalid_delete_blob", record: :none) do
        registry = described_class.new(
          registry_server,
          false,
          "portus",
          Rails.application.secrets.portus_password
        )

        expect do
          registry.delete("busybox",
                          "sha256:a3ed95caeb02ffe68cdd9fd84406680ae93d633cb16422d00e8a7c22955b46d4")
        end.to raise_error ::Portus::RegistryClient::RegistryError
      end
    end
  end
end
