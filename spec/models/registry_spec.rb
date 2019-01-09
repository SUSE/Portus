# frozen_string_literal: true

# == Schema Information
#
# Table name: registries
#
#  id                :integer          not null, primary key
#  name              :string(255)      not null
#  hostname          :string(255)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  use_ssl           :boolean
#  external_hostname :string(255)
#
# Indexes
#
#  index_registries_on_hostname  (hostname) UNIQUE
#  index_registries_on_name      (name) UNIQUE
#

require "rails_helper"

# Open up Portus::RegistryClient to inspect some attributes.
Portus::RegistryClient.class_eval do
  attr_reader :host, :use_ssl, :base_url, :username, :password
end

# Mock class that returns a client that can fail depending on how this class is
# initialized.
class RegistryMock < Registry
  def initialize(should_fail)
    @should_fail = should_fail
  end

  def client
    o = nil
    if @should_fail
      def o.manifest(*_)
        raise ::Portus::RegistryClient::ManifestError, "Some message"
      end

      def o.tags(*_)
        raise ::Portus::RegistryClient::ManifestError, "Some message"
      end
    else
      def o.manifest(*_)
        manifest = { "tag" => "latest", "config": { "size": 1000 }, "layers": [] }

        OpenStruct.new(id: "id", digest: "digest", size: 1000, manifest: manifest)
      end

      def o.tags(*_)
        ["latest", "0.1"]
      end
    end
    o
  end

  def get_tag_from_target_test(namespace, repo, mtype, digest, tag = nil)
    target = { "mediaType" => mtype, "repository" => repo, "digest" => digest }
    target["tag"] = tag unless tag.nil?
    get_tag_from_target(namespace, repo, target)
  end
end

def create_empty_namespace
  owner = create(:user)
  team = create(:team, owners: [owner])
  create(:namespace, team: team)
end

describe Registry, type: :model do
  it { is_expected.to have_many(:namespaces) }

  describe "after_create" do
    it "creates namespaces after_create" do
      create(:admin)
      create(:user)
      expect(Namespace.count).to be(0)

      create(:registry)
      User.all.each { |user| expect(user.namespace).not_to be(nil) }
    end

    it "#create_namespaces!" do
      # NOTE: the :registry factory already creates an admin
      create(:admin)
      registry = create(:registry)

      owners = registry.global_namespace.team.owners.order(username: :asc)
      users = User.where(admin: true).order(username: :asc)

      expect(owners.count).to be(2)
      expect(users).to match_array(owners)
    end
  end

  describe "#client" do
    let!(:registry) { create(:registry, use_ssl: true) }

    it "returns a client with the proper config" do
      client = registry.client

      expect(client.host).to eq registry.hostname
      expect(client.use_ssl).to be_truthy
      expect(client.base_url).to eq "https://#{registry.hostname}/v2/"
      expect(client.username).to eq "portus"
      expect(client.password).to eq Rails.application.secrets.portus_password
    end
  end

  describe "#reachable_hostname" do
    let!(:registry) { create(:registry, use_ssl: true) }
    let!(:registry_external) { create(:registry, external_hostname: "external", use_ssl: true) }

    it "returns internal hostname when external not present" do
      expect(registry.reachable_hostname).to eq registry.hostname
    end

    it "returns external hostname whenever is present" do
      expect(registry_external.reachable_hostname).to eq registry_external.external_hostname
    end
  end

  describe "#reachable" do
    after :each do
      allow_any_instance_of(::Portus::RegistryClient).to receive(:perform_request).and_call_original
    end

    it "returns the proper message for each scenario" do
      GOOD_RESPONSE = OpenStruct.new(code: 401, header:
        { "Docker-Distribution-Api-Version" => "registry/2.0" })

      [
        [nil, GOOD_RESPONSE, true, /^$/],
        [nil, nil, true, /registry does not implement v2/],
        [SocketError, GOOD_RESPONSE, true, /connection refused/],
        [Errno::ECONNREFUSED, GOOD_RESPONSE, true, /connection refused/],
        [Errno::ETIMEDOUT, GOOD_RESPONSE, true, /connection timed out/],
        [Net::OpenTimeout, GOOD_RESPONSE, true, /connection timed out/],
        [Net::HTTPBadResponse, GOOD_RESPONSE, true, /could not stablish connection: SSL error/],
        [OpenSSL::SSL::SSLError, GOOD_RESPONSE, true, /could not stablish connection: SSL error/],
        [OpenSSL::SSL::SSLError, GOOD_RESPONSE, false, /could not stablish connection: SSL error/],
        [Errno::ECONNRESET, GOOD_RESPONSE, false, /connection reset/]
      ].each do |cs|
        allow_any_instance_of(::Portus::RegistryClient).to receive(:perform_request) do
          raise cs.first if cs.first

          cs[1]
        end
        r = Registry.new(hostname: "something", name: "test", use_ssl: cs[2])
        expect(r.reachable?).to match(cs.last)
      end
    end
  end

  describe "#get_tag_from_manifest" do
    it "returns a tag on v2 manifests" do
      owner     = create(:user)
      team      = create(:team, owners: [owner])
      namespace = create(:namespace, team: team)
      repo      = create(:repository, name: "busybox", namespace: namespace)
      create(:tag, name: "latest", repository: repo)

      mock = RegistryMock.new(false)
      ret  = mock.get_tag_from_target_test(namespace, "busybox",
                                           "application/vnd.docker.distribution.manifest.v2+json",
                                           "sha:1234")
      expect(ret).to eq "0.1"

      # Differentiate between global & local namespace

      ret = mock.get_tag_from_target_test(create_empty_namespace,
                                          "busybox",
                                          "application/vnd.docker.distribution.manifest.v2+json",
                                          "sha:1234")
      expect(ret).to eq "latest"
    end

    it "returns the tags on an unknown repository" do
      mock = RegistryMock.new(false)
      ret  = mock.get_tag_from_target_test(create_empty_namespace,
                                           "busybox",
                                           "application/vnd.docker.distribution.manifest.v2+json",
                                           "sha:1234")
      expect(ret).to eq "latest"
    end

    it "handles errors properly" do
      m = RegistryMock.new(true)

      expect(Rails.logger).to receive(:info).with(/Could not fetch the tag/)
      expect(Rails.logger).to receive(:info).with(/Reason: Some message/)

      ret = m.get_tag_from_target_test(nil, "busybox",
                                       "application/vnd.docker.distribution.manifest.v1+prettyjws",
                                       "sha:1234")
      expect(ret).to be_nil
    end

    it "handles errors on v2" do
      mock = RegistryMock.new(true)

      expect(Rails.logger).to receive(:info).with(/Could not fetch the tag/)
      expect(Rails.logger).to receive(:info).with(/Reason: Some message/)

      ret = mock.get_tag_from_target_test(create_empty_namespace,
                                          "busybox",
                                          "application/vnd.docker.distribution.manifest.v2+json",
                                          "sha:1234")
      expect(ret).to be_nil
    end

    it "raises an error when the mediaType is unknown" do
      mock = RegistryMock.new(true)

      expect(Rails.logger).to receive(:info).with(/Could not fetch the tag/)
      expect(Rails.logger).to receive(:info).with(/Reason: unsupported media type "a"/)

      mock.get_tag_from_target_test(nil, "busybox", "a", "sha:1234")
    end

    it "fetches the tag from the target if it exists" do
      mock = RegistryMock.new(false)

      # We leave everything empty to show that if the tag is provided, we pick
      # it, regardless of any other information.
      ret  = mock.get_tag_from_target_test(nil, "", "", "", "0.1")
      expect(ret).to eq "0.1"
    end
  end

  describe "#by_hostname_or_external" do
    let!(:registry) { create(:registry, hostname: "a", external_hostname: "b") }

    it "returns the given registry by hostname" do
      expect(Registry.by_hostname_or_external("a")).to eq(registry)
    end

    it "returns the given registry by external hostname" do
      expect(Registry.by_hostname_or_external("b")).to eq(registry)
    end

    it "returns nil if the given hostname cannot be found" do
      expect(Registry.by_hostname_or_external("c")).to be_nil
    end
  end
end
