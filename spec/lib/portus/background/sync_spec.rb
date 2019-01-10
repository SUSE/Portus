# frozen_string_literal: true

require "rails_helper"
require "portus/background/sync"

# Just opens up protected methods so they can be used in the test suite.
class SyncMock < ::Portus::Background::Sync
  def update_registry!(catalog)
    super
  end
end

describe ::Portus::Background::Sync do
  before do
    APP_CONFIG["background"]["sync"] = {
      "enabled"  => true,
      "strategy" => "update-delete"
    }
  end

  describe "#sleep_value" do
    it "returns always 20" do
      expect(subject.sleep_value).to eq 20
    end
  end

  describe "#work?" do
    it "returns false if this feature is disabled" do
      APP_CONFIG["background"]["sync"]["enabled"] = false
      expect(subject.work?).to be_falsey
    end

    it "returns false on an unrecognized value" do
      APP_CONFIG["background"]["sync"]["strategy"] = "Wubba Lubba Dub Dub"

      expect(Rails.logger).to receive(:error).with("Unrecognized value " \
                                                   "'Wubba Lubba Dub Dub' for strategy")
      expect(subject.work?).to be_falsey
    end

    it "returns true if it's update or update-delete" do
      APP_CONFIG["background"]["sync"]["strategy"] = "update"
      expect(subject.work?).to be_truthy
      APP_CONFIG["background"]["sync"]["strategy"] = "update-delete"
      expect(subject.work?).to be_truthy
    end

    it "returns the same value as @executed on 'on-start'" do
      APP_CONFIG["background"]["sync"]["strategy"] = "on-start"
      expect(subject.work?).to be_truthy

      create(:registry)
      allow_any_instance_of(::Portus::RegistryClient).to receive(:catalog).and_return("")
      allow_any_instance_of(::Portus::Background::Sync).to receive(:update_registry!) {}
      subject.execute!

      expect(subject.work?).to be_falsey
    end

    it "returns the same value as @executed on 'initial'" do
      APP_CONFIG["background"]["sync"]["strategy"] = "initial"
      expect(subject.work?).to be_truthy

      create(:registry)
      allow_any_instance_of(::Portus::RegistryClient).to receive(:catalog).and_return("")
      allow_any_instance_of(::Portus::Background::Sync).to receive(:update_registry!) {}
      subject.execute!

      expect(subject.work?).to be_falsey
    end

    it "returns true if on 'initial' if there was no registry" do
      APP_CONFIG["background"]["sync"]["strategy"] = "initial"
      expect(subject.work?).to be_truthy
      subject.execute!
      expect(subject.work?).to be_truthy
    end
  end

  describe "#execute!" do
    describe "Empty database" do
      let!(:manifest) { OpenStruct.new(id: "", digest: "") }

      it "updates the registry" do
        allow_any_instance_of(::Portus::RegistryClient).to receive(:manifest).and_return(manifest)

        registry  = create(:registry)
        namespace = create(:namespace, registry: registry)

        sync = SyncMock.new
        sync.update_registry!([{ "name" => "busybox", "tags" => ["latest", "0.1"] },
                               { "name" => "alpine", "tags" => ["latest"] },
                               { "name" => "#{namespace.name}/alpine", "tags" => ["latest"] }])

        # Global repos.
        ns = Namespace.where(global: true)
        repos = Repository.where(namespace: ns)
        expect(repos.map(&:name).sort).to match_array(%w[alpine busybox])
        tags = Repository.find_by(name: "busybox").tags
        expect(tags.map(&:name)).to match_array(["0.1", "latest"])
        tags = Repository.find_by(name: "alpine", namespace: ns).tags
        expect(tags.map(&:name)).to match_array(["latest"])

        # Local repos.
        repos = Repository.where(namespace: namespace)
        expect(repos.map(&:name).sort).to match_array(["alpine"])
        tags = repos.first.tags
        expect(tags.map(&:name)).to match_array(["latest"])
      end

      it "does nothing if there is no registry" do
        sync = SyncMock.new
        expect { sync.execute! }.not_to raise_error
      end

      it "raises an exception when there has been a problem in /v2/_catalog" do
        VCR.turn_on!

        create(:registry, "hostname" => "registry.test.lan")

        VCR.use_cassette("registry/get_missing_catalog_endpoint", record: :none) do
          sync = SyncMock.new
          expect(Rails.logger).to receive(:warn).with(/page not found/)
          sync.execute!
        end
      end

      it "executes the task as expected" do
        VCR.turn_on!

        allow_any_instance_of(::Portus::RegistryClient).to receive(:manifest).and_return(manifest)
        registry = create(:registry, "hostname" => "registry.test.lan")

        VCR.use_cassette("registry/get_registry_catalog", record: :none) do
          sync = SyncMock.new
          sync.execute!
        end

        repos = Repository.all
        expect(repos.count).to eq 1
        repo = repos[0]
        expect(repo.name).to eq "busybox"
        expect(repo.namespace.id).to eq registry.namespaces.first.id
        tags = repo.tags
        expect(tags.map(&:name)).to match_array(["latest"])
      end

      it "handles registries and namespaces even with missing namespaces" do
        VCR.turn_on!

        allow_any_instance_of(::Portus::RegistryClient).to receive(:manifest).and_return(manifest)
        registry = create(:registry, "hostname" => "registry.test.lan")

        # In this scenario, we have only the global namespace
        VCR.use_cassette("registry/get_registry_catalog_namespace_missing", record: :none) do
          sync = SyncMock.new
          sync.execute!
        end

        repos = Repository.all
        repo = repos[1]
        repo_missing = repos[0]

        expect(repos.count).to eq 2
        expect(repo.full_name).to eq "busybox"
        expect(repo_missing.full_name).to eq "missing/busybox"
        expect(repo.namespace.id).to eq registry.namespaces.first.id
        expect(repo_missing.namespace.name).to eq "missing"
        expect(repo.tags.map(&:name)).to match_array(["latest"])
        expect(repo_missing.tags.map(&:name)).to match_array(["latest", "2.0"])
      end
    end

    describe "Database already filled with repos" do
      let!(:registry)    { create(:registry, "hostname" => "registry.test.lan") }
      let!(:owner)       { create(:user) }
      let!(:namespace)   { create(:namespace, registry: registry) }
      let!(:repo1)       { create(:repository, name: "repo1", namespace: namespace) }
      let!(:repo2)       { create(:repository, name: "repo2", namespace: namespace) }
      let!(:tag1)        { create(:tag, name: "tag1", repository: repo1) }
      let!(:tag2)        { create(:tag, name: "tag2", repository: repo2) }
      let!(:tag3)        { create(:tag, name: "tag3", repository: repo2) }
      let!(:manifest)    { OpenStruct.new(id: "", digest: "") }

      it "updates the registry" do
        allow_any_instance_of(::Portus::RegistryClient).to receive(:manifest).and_return(manifest)

        sync = SyncMock.new
        sync.update_registry!([{ "name" => "busybox", "tags" => ["latest", "0.1"] },
                               { "name" => "#{namespace.name}/repo1",  "tags" => ["latest"] },
                               { "name" => "#{namespace.name}/repo2",  "tags" => %w[latest tag2] },
                               { "name" => "#{namespace.name}/alpine", "tags" => ["latest"] }])

        # Global repos
        ns = Namespace.where(global: true)
        repos = Repository.where(namespace: ns)
        expect(repos.map(&:name).sort).to match_array(["busybox"])
        tags = repos.first.tags
        expect(tags.map(&:name).sort).to match_array(["0.1", "latest"])

        # User namespaces.
        repos = Repository.where(namespace: namespace)
        expect(repos.map(&:name).sort).to match_array(%w[alpine repo1 repo2])
        tags = Repository.find_by(name: "alpine").tags
        expect(tags.map(&:name)).to match_array(["latest"])
        tags = Repository.find_by(name: "repo1").tags
        expect(tags.map(&:name)).to match_array(["latest"])
        tags = Repository.find_by(name: "repo2").tags
        expect(tags.map(&:name)).to match_array(%w[latest tag2])
      end

      it "does not remove old repositories if we are using 'update'" do
        APP_CONFIG["background"]["sync"]["strategy"] = "update"

        allow_any_instance_of(::Portus::RegistryClient).to receive(:manifest).and_return(manifest)

        # With this "repo2" should be removed, but since we are on "update" this
        # won't happen.
        sync = SyncMock.new
        sync.update_registry!([{ "name" => "busybox", "tags" => ["latest", "0.1"] },
                               { "name" => "#{namespace.name}/repo1",  "tags" => ["latest"] }])

        # Global repos
        ns = Namespace.where(global: true)
        repos = Repository.where(namespace: ns)
        expect(repos.map(&:name).sort).to match_array(["busybox"])
        tags = repos.first.tags
        expect(tags.map(&:name).sort).to match_array(["0.1", "latest"])

        # User namespaces.
        repos = Repository.where(namespace: namespace)
        expect(repos.map(&:name).sort).to match_array(%w[repo1 repo2])
        tags = Repository.find_by(name: "repo1").tags
        expect(tags.map(&:name)).to match_array(["latest"])
        tags = Repository.find_by(name: "repo2").tags
        expect(tags.map(&:name)).to match_array(%w[tag2 tag3])
      end

      it "does not remove a repository with nil tags on update-delete" do
        APP_CONFIG["background"]["sync"]["strategy"] = "update-delete"

        allow_any_instance_of(::Portus::RegistryClient).to receive(:manifest).and_return(manifest)

        # repo2 is not removed because it exists and the tags is nil. This
        # happens when fetching tags raised a handled exception.
        sync = SyncMock.new
        sync.update_registry!([{ "name" => "busybox", "tags" => ["latest", "0.1"] },
                               { "name" => "#{namespace.name}/repo1",  "tags" => ["latest"] },
                               { "name" => "#{namespace.name}/repo2",  "tags" => nil }])

        r = Repository.find_by(name: "repo2")
        expect(r.tags.size).to eq 2
      end

      it "does not remove a repository when its tags raised an exception" do
        APP_CONFIG["background"]["sync"]["strategy"] = "update-delete"

        VCR.turn_on!

        allow_any_instance_of(::Portus::RegistryClient).to receive(:manifest).and_return(manifest)
        allow_any_instance_of(::Portus::RegistryClient).to receive(:tags) do
          raise ::Portus::Errors::NotFoundError, "I AM ERROR"
        end

        ns = Namespace.where(global: true).first
        busybox = create(:repository, name: "busybox", namespace: ns)
        create(:tag, name: "doesnotexist", repository: busybox)

        VCR.use_cassette("registry/get_registry_catalog", record: :none) do
          sync = SyncMock.new
          sync.execute!
        end

        expect(Repository.count).to eq 1
        expect(Repository.first.tags.size).to eq 1
      end
    end

    describe "uploading repository whose tags is nil" do
      it "skip this repository" do
        sync = SyncMock.new
        sync.update_registry!([{ "name" => "busybox", "tags" => nil }])

        # Global repos
        ns = Namespace.where(global: true)
        repos = Repository.where(namespace: ns)
        expect(repos.length).to eq 0
      end
    end

    describe "Activities are updated accordingly" do
      let!(:registry)   { create(:registry) }
      let!(:owner)      { create(:user) }
      let!(:repo)       { create(:repository, name: "repo", namespace: registry.global_namespace) }
      let!(:tag)        { create(:tag, name: "latest", author: owner, repository: repo) }
      let!(:manifest)   { OpenStruct.new(id: "", digest: "") }

      it "removes activities from dangling tags" do
        allow_any_instance_of(::Portus::RegistryClient).to receive(:manifest).and_return(manifest)

        repo.create_activity(:push, owner: owner, recipient: tag)

        activities = PublicActivity::Activity.order(:updated_at)
        expect(activities.count).to eq 1
        expect(activities.first.parameters[:tag_name]).to be_nil

        sync = SyncMock.new
        sync.update_registry!([{ "name" => "repo", "tags" => ["0.1"] }])

        # Three activities: the original one, one more push for 0.1 and then the
        # delete for latest.
        activities = PublicActivity::Activity.order(:updated_at)
        expect(activities.count).to eq 3
        expect(activities.first.parameters[:tag_name]).to eq "latest"
        expect(activities[1].recipient.name).to eq "0.1"
        expect(activities.last.key).to eq "repository.delete"
      end
    end

    it "rolls back if an event happened while syncing" do
      manifest = OpenStruct.new(id: "", digest: "")
      registry = create(:registry)
      owner = create(:user)
      repo = create(:repository, name: "repo", namespace: registry.global_namespace)
      create(:tag, name: "latest", author: owner, repository: repo)

      # Event!
      RegistryEvent.create!(event_id: "id", data: "", status: RegistryEvent.statuses[:fresh])

      allow_any_instance_of(::Portus::RegistryClient).to receive(:manifest).and_return(manifest)
      sync = SyncMock.new

      expect do
        sync.update_registry!([{ "name" => "repo", "tags" => ["0.1"] }])
      end.to raise_error(ActiveRecord::Rollback)
    end
  end

  describe "#enabled?" do
    it "returns true when enabled" do
      APP_CONFIG["background"]["sync"] = { "enabled" => true }
      expect(subject.enabled?).to be_truthy
    end

    it "returns false when not enabled" do
      APP_CONFIG["background"]["sync"] = { "enabled" => false }
      expect(subject.enabled?).to be_falsey
    end

    it "returns false on initial if there are repositories" do
      APP_CONFIG["background"]["sync"] = {
        "enabled"  => true,
        "strategy" => "initial"
      }

      registry = create(:registry)
      create(:user)
      namespace = create(:namespace, registry: registry)
      repo = create(:repository, name: "repo", namespace: namespace)
      create(:tag, name: "tag", repository: repo)

      expect(subject.enabled?).to be_falsey
    end
  end

  describe "#disable?" do
    it "returns false on update or update-delete" do
      APP_CONFIG["background"]["sync"]["strategy"] = "update"
      expect(subject.disable?).to be_falsey
      APP_CONFIG["background"]["sync"]["strategy"] = "update-delete"
      expect(subject.disable?).to be_falsey
    end

    it "returns whatever @executed contains on initial" do
      APP_CONFIG["background"]["sync"]["strategy"] = "initial"
      expect(subject.disable?).to be_falsey

      create(:registry)
      allow_any_instance_of(::Portus::RegistryClient).to receive(:catalog).and_return("")
      allow_any_instance_of(::Portus::Background::Sync).to receive(:update_registry!) {}
      subject.execute!

      expect(subject.disable?).to be_truthy
    end

    it "returns whatever @executed contains on on-start" do
      APP_CONFIG["background"]["sync"]["strategy"] = "on-start"
      expect(subject.disable?).to be_falsey

      create(:registry)
      allow_any_instance_of(::Portus::RegistryClient).to receive(:catalog).and_return("")
      allow_any_instance_of(::Portus::Background::Sync).to receive(:update_registry!) {}
      subject.execute!

      expect(subject.disable?).to be_truthy
    end

    it "returns false if no registry was set" do
      APP_CONFIG["background"]["sync"]["strategy"] = "initial"
      expect(subject.disable?).to be_falsey
      subject.execute!
      expect(subject.disable?).to be_falsey
    end
  end

  describe "#disable_message" do
    it "works" do
      expect(subject.disable_message).to eq "task was ordered to execute once, " \
                                            "and this has already been performed"
    end
  end

  describe "#to_s" do
    it "works" do
      expect(subject.to_s).to eq "Registry synchronization"
    end
  end
end
