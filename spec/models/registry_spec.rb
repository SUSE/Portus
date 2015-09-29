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
        raise StandardError, "Some message"
      end
    else
      def o.manifest(*_)
        { "tag" => "latest" }
      end
    end
    o
  end

  def get_tag_from_manifest_test(repo, digest)
    target = { repository: repo, digest: digest }
    get_tag_from_manifest(target)
  end
end

RSpec.describe Registry, type: :model do
  it { should have_many(:namespaces) }

  describe "after_create" do
    it "creates namespaces after_create" do
      create(:admin)
      create(:user)
      expect(Namespace.count).to be(0)

      create(:registry)
      User.all.each do |user|
        expect(Namespace.find_by(name: user.username)).not_to be(nil)
      end
    end

    it "#create_namespaces!" do
      # NOTE: the :registry factory already creates an admin
      create(:admin)
      registry = create(:registry)

      owners = registry.global_namespace.team.owners.order("username ASC")
      users = User.where(admin: true).order("username ASC")

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

  describe "#get_tag_from_manifest" do
    it "returns a tag on success" do
      mock = RegistryMock.new(false)

      ret = mock.get_tag_from_manifest_test("busybox", "sha:1234")
      expect(ret).to eq "latest"
    end

    it "handles errors properly" do
      mock = RegistryMock.new(true)

      expect(Rails.logger).to receive(:info).with(/Could not fetch the tag/)
      expect(Rails.logger).to receive(:info).with(/Reason: Some message/)

      ret = mock.get_tag_from_manifest_test("busybox", "sha:1234")
      expect(ret).to be_nil
    end
  end
end
