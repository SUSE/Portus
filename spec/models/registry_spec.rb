require "rails_helper"

# Open up Portus::RegistryClient to inspect some attributes.
Portus::RegistryClient.class_eval do
  attr_reader :host, :use_ssl, :base_url, :username, :password
end

RSpec.describe Registry, type: :model do
  it { should have_many(:namespaces) }

  describe "#create_global_namespace" do
    it "adds all existing admins to the global team" do
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
end
