# frozen_string_literal: true

require "rails_helper"

# Just opens up protected methods so they can be used in the test suite.
class SyncMock < ::Portus::Background::Sync
  def update_registry!(catalog)
    super
  end
end

RSpec.describe RepositoriesHelper, type: :helper do
  include NamespacesHelper

  describe "#render_repository_information" do
    let(:registry)    { create(:registry) }
    let(:admin)       { create(:admin) }
    let(:owner)       { create(:user) }
    let(:viewer)      { create(:user) }
    let(:contributor) { create(:user) }
    let(:team) do
      create(:team,
             owners:       [owner],
             contributors: [contributor],
             viewers:      [viewer])
    end
    let(:namespace) { create(:namespace, team: team) }
    let(:repo)      { create(:repository, namespace: namespace) }

    it "shows you can push images" do
      sign_in owner
      message = helper.render_repository_information(repo)
      expect(message).to include("You can push images")
    end

    context "when the user push permission is restrictred" do
      before do
        APP_CONFIG["user_permission"]["push_images"]["policy"] = "allow-personal"
      end

      it "shows you can push images only for admins" do
        sign_in owner
        message = helper.render_repository_information(repo)
        expect(message).not_to include("You can push images")
      end
    end

    it "shows you can pull images" do
      sign_in owner
      message = helper.render_repository_information(repo)
      expect(message).to include("You can pull images")
    end

    it "shows you are an owner" do
      sign_in owner
      message = helper.render_repository_information(repo)
      expect(message).to include("You are an owner of this repository")
    end

    it "shows you are a contributor" do
      sign_in contributor
      message = helper.render_repository_information(repo)
      expect(message).to include("You are a contributor in this repository")
    end

    it "shows you are a viewer" do
      sign_in viewer
      message = helper.render_repository_information(repo)
      expect(message).to include("You are a viewer in this repository")
    end
  end

  describe "#render_push_activity" do
    let!(:registry)   { create(:registry, hostname: "registry:5000") }
    let!(:namespace)  { create(:namespace, name: "namespace", registry: registry) }
    let!(:owner)      { create(:user) }
    let!(:unknown)    { create(:user) }
    let!(:portus)     { User.create_portus_user! }
    let!(:repo)       { create(:repository, name: "repo", namespace: registry.global_namespace) }
    let!(:repo1)      { create(:repository, name: "repo1", namespace: registry.global_namespace) }
    let!(:repo2)      { create(:repository, name: "repo2", namespace: registry.global_namespace) }
    let!(:repo3)      { create(:repository, name: "repo3", namespace: namespace) }
    let!(:tag)        { create(:tag, name: "latest", author: owner, repository: repo) }
    let!(:tag1)       { create(:tag, name: "0.1", author: owner, repository: repo) }
    let!(:tag2)       { create(:tag, name: "0.2", author: owner, repository: repo1) }
    let!(:tag3)       { create(:tag, name: "0.3", author: owner, repository: repo2) }
    let!(:tag4)       { create(:tag, name: "0.4", author: owner, repository: repo3) }
    let!(:tag5)       { create(:tag, name: "0.5", author: unknown, repository: repo3) }
    let!(:manifest)   { OpenStruct.new(id: "", digest: "") }

    it "creates the proper HTML for each kind of activity" do
      allow_any_instance_of(::Portus::RegistryClient).to receive(:manifest).and_return(manifest)

      repo.create_activity(:push, owner: owner, recipient: tag, created_at: 5.hours.ago)
      repo.create_activity(:push, owner: owner, recipient: tag1, created_at: 4.hours.ago)
      repo1.create_activity(:push, owner: owner, recipient: tag2, created_at: 3.hours.ago)
      repo1.create_activity(:push, owner: nil, recipient: tag3, created_at: 2.hours.ago)
      repo3.create_activity(:push, owner: portus, recipient: tag4, created_at: 1.hour.ago)
      repo3.create_activity(:push, owner: unknown, recipient: tag5, created_at: 1.minute.ago)

      tag1.destroy
      repo1.destroy
      unknown.update_activities!(portus)
      unknown.destroy

      nameo  = owner.username
      global = registry.global_namespace.id

      expectations = [
        "<strong>#{nameo} pushed </strong><a href=\"/namespaces/#{global}\">registry:5000</a>/"\
          "<a href=\"/repositories/#{repo.id}\">repo:latest</a>",
        "<strong>#{nameo} pushed </strong><a href=\"/namespaces/#{global}\">registry:5000</a>/"\
          "<a href=\"/repositories/#{repo.id}\">repo</a>",
        "<strong>#{nameo} pushed </strong><span>a repository</span>",
        "<strong>Someone pushed </strong><span>a repository</span>",
        "<strong>portus pushed (sync) </strong><a href=\"/namespaces/#{namespace.id}\">"\
          "namespace</a>/<a href=\"/repositories/#{repo3.id}\">repo3:0.4</a>",
        "<strong>#{unknown.username} pushed </strong><a href=\"/namespaces/#{namespace.id}\">"\
          "namespace</a>/<a href=\"/repositories/#{repo3.id}\">repo3:0.5</a>"
      ]

      idx = 0
      wh = { key: "repository.push" }
      PublicActivity::Activity.where(wh).order(id: :asc).each do |activity|
        html = render_push_activity(activity)
        expect(html).to eq expectations[idx]
        idx += 1
      end

      # And now the catalog job sweeps in.
      sync = SyncMock.new
      sync.update_registry!([{ "name" => "repo", "tags" => ["0.1"] }])

      # Let's remove the other namespace, to force another case.
      namespace.destroy

      idx = 0

      na = "<strong>portus pushed (sync) </strong><a href=\"/namespaces/#{global}\">registry:5000"\
           "</a>/<a href=\"/repositories/#{repo.id}\">repo:0.1</a>"
      expectations = expectations.push(na)

      # Changes because of the Catalog job.
      expectations[3] = "<strong>Someone pushed </strong><a href=\"/namespaces/#{global}\">"\
        "registry:5000</a>/<span>repo2:0.3</span>"
      expectations[4] = "<strong>portus pushed (sync) </strong><span>namespace</span>/<span>repo"\
        "3:0.4</span>"
      expectations[5] = "<strong>Someone pushed </strong><span>namespace</span>/<span>repo3"\
        ":0.5</span>"

      # Push activities
      PublicActivity::Activity.where(wh).order(id: :asc).each do |activity|
        html = render_push_activity(activity)
        expect(html).to eq expectations[idx]
        idx += 1
      end

      idx = 0
      expectations = [
        "<strong>portus deleted (sync) </strong><a href=\"/namespaces/#{global}\">registry:5000"\
          "</a>/<a href=\"/repositories/#{repo.id}\">repo:latest</a>",
        "<strong>portus deleted (sync) </strong><a href=\"/namespaces/#{global}\">registry:5000"\
          "</a>/<span>repo2:0.3</span>",
        "<strong>portus deleted (sync) </strong><span>namespace</span>/<span>repo3:0.4</span>",
        "<strong>portus deleted (sync) </strong><a href=\"/namespaces/#{global}\">registry:5000"\
          "</a>/<span>repo2</span>",
        "<strong>portus deleted (sync) </strong><span>namespace</span>/<span>repo3:0.5</span>",
        "<strong>portus deleted (sync) </strong><span>namespace</span>/<span>repo3</span>"
      ]

      # Delete Activities
      wh = "activities.key='repository.delete' OR activities.key='namespace.delete'"
      PublicActivity::Activity.where(wh).order(id: :asc).each do |activity|
        html = render_delete_activity(activity)
        expect(expectations).to include(html)
        idx += 1
      end
    end
  end

  describe "#security_vulns_enabled?" do
    it "returns true if any security vulnerability server is configured" do
      enable_security_vulns_module!

      expect(helper).to be_security_vulns_enabled
    end

    it "returns false if no security vulnerability server is configured" do
      expect(helper).not_to be_security_vulns_enabled
    end
  end

  describe "#vulnerable?" do
    it "returns true if any security vulnerability server is configured" do
      vulnerabilities = {
        one: [[]],
        two: []
      }

      expect(helper).to be_vulnerable(vulnerabilities)
    end

    it "returns false if no vulnerabilities were found" do
      expect(helper).not_to be_vulnerable(nil)
    end

    it "returns false if no security vulnerability server is configured" do
      vulnerabilities = {
        one: [],
        two: []
      }

      expect(helper).not_to be_vulnerable(vulnerabilities)
    end
  end
end
