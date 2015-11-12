require "rails_helper"

# Auxiliar method to get the URL format used in this spec file.
def get_url(repo, tag)
  "http://registry.test.lan/v2/#{repo}/manifests/#{tag}"
end

describe Repository do
  it { should belong_to(:namespace) }
  it { should have_many(:tags) }
  it { should have_many(:stars) }

  describe "starrable behaviour" do
    let(:user) { create(:user) }
    let(:repository) { create(:repository) }
    let(:star) { create(:star, user: user, repository: repository) }
    let(:other_user) { create(:user) }

    it "should identify if it is already starred by a user" do
      expect(star.repository.starred_by?(user)).to be true
      expect(star.repository.starred_by?(other_user)).to be false
    end

    it "should be starrable by a user" do
      repository.toggle_star(user)
      expect(repository.starred_by?(user)).to be true
      expect(repository.starred_by?(other_user)).to be false
    end

    it "should be unstarrable by a user" do
      repository = star.repository
      repository.toggle_star(user)
      expect(repository.starred_by?(user)).to be false
      expect(repository.starred_by?(other_user)).to be false
    end
  end

  describe "handle push event" do
    let(:tag_name) { "latest" }
    let(:repository_name) { "busybox" }
    let(:registry) { create(:registry, hostname: "registry.test.lan") }
    let(:user) { create(:user) }

    context "adding an existing repo/tag" do
      it "does not add a new activity when an already existing repo/tag already existed" do
        event = { "actor" => { "name" => user.username } }

        # First we create it, and make sure that it creates the activity.
        expect do
          Repository.add_repo(event, registry.global_namespace, repository_name, tag_name)
        end.to change(PublicActivity::Activity, :count).by(1)

        # And now it shouldn't create more activities.
        expect do
          Repository.add_repo(event, registry.global_namespace, repository_name, tag_name)
        end.to change(PublicActivity::Activity, :count).by(0)
      end
    end

    context "event does not match regexp of manifest" do
      let(:event) do
        e = build(:raw_push_manifest_event).to_test_hash
        e["target"]["repository"] = repository_name
        e["target"]["url"] = "http://registry.test.lan/v2/#{repository_name}/wrong/#{tag_name}"
        e["request"]["host"] = registry.hostname
        e
      end

      it "sends event to logger" do
        VCR.use_cassette("registry/get_image_manifest_webhook", record: :none) do
          expect do
            Repository.handle_push_event(event)
          end.to change(Repository, :count).by(0)
        end
      end
    end

    context "event comes from an unknown registry" do
      before :each do
        @event = build(:raw_push_manifest_event).to_test_hash
        @event["target"]["repository"] = repository_name
        @event["target"]["url"] = get_url(repository_name, tag_name)
        @event["request"]["host"] = "unknown-registry.test.lan"
        @event["actor"]["name"] = user.username
      end

      it "sends event to logger" do
        expect(Rails.logger).to receive(:info)
        expect do
          Repository.handle_push_event(@event)
        end.to change(Repository, :count).by(0)
      end
    end

    context "event comes from an unknown user" do
      before :each do
        @event = build(:raw_push_manifest_event).to_test_hash
        @event["target"]["repository"] = repository_name
        @event["target"]["url"] = get_url(repository_name, tag_name)
        @event["request"]["host"] = registry.hostname
        @event["actor"]["name"] = "a_ghost"
      end

      it "sends event to logger" do
        expect do
          Repository.handle_push_event(@event)
        end.to change(Repository, :count).by(0)
      end

    end

    context "when dealing with a top level repository" do
      before :each do
        @event = build(:raw_push_manifest_event).to_test_hash
        @event["target"]["repository"] = repository_name
        @event["target"]["url"] = get_url(repository_name, "digest")
        @event["target"]["digest"] = "digest"
        @event["request"]["host"] = registry.hostname
        @event["actor"]["name"] = user.username
      end

      context "when the repository is not known by Portus" do
        it "should create repository and tag objects" do
          repository = nil
          VCR.use_cassette("registry/get_image_manifest_webhook", record: :none) do
            expect do
              repository = Repository.handle_push_event(@event)
            end.to change(Namespace, :count).by(0)
          end

          expect(repository).not_to be_nil
          expect(Repository.count).to eq 1
          expect(Tag.count).to eq 1

          expect(repository.namespace).to eq(registry.global_namespace)
          expect(repository.name).to eq(repository_name)
          expect(repository.tags.count).to eq 1
          expect(repository.tags.first.name).to eq tag_name
          expect(repository.tags.find_by(name: tag_name).author).to eq(user)
        end

        it "tracks the event" do
          repository = nil
          VCR.use_cassette("registry/get_image_manifest_webhook", record: :none) do
            expect do
              repository = Repository.handle_push_event(@event)
            end.to change(PublicActivity::Activity, :count).by(1)
          end

          activity = PublicActivity::Activity.last
          expect(activity.key).to eq("repository.push")
          expect(activity.owner).to eq(user)
          expect(activity.trackable).to eq(repository)
          expect(activity.recipient).to eq(repository.tags.last)
          expect(repository.tags.find_by(name: tag_name).author).to eq(user)
        end
      end

      context "when a new version of an already known repository" do
        before :each do
          repository = create(:repository, name:      repository_name,
                                           namespace: registry.global_namespace)
          repository.tags << Tag.new(name: "1.0.0")
        end

        it "should create a new tag" do
          repository = nil
          VCR.use_cassette("registry/get_image_manifest_webhook", record: :none) do
            expect do
              repository = Repository.handle_push_event(@event)
            end.to change(Namespace, :count).by(0)
          end

          expect(repository).not_to be_nil
          expect(Repository.count).to eq 1
          expect(Tag.count).to eq 2

          expect(repository.namespace).to eq(registry.global_namespace)
          expect(repository.name).to eq(repository_name)
          expect(repository.tags.count).to eq 2
          expect(repository.tags.map(&:name)).to include("1.0.0", tag_name)
          expect(repository.tags.find_by(name: tag_name).author).to eq(user)
        end

        it "tracks the event" do
          repository = nil
          VCR.use_cassette("registry/get_image_manifest_webhook", record: :none) do
            expect do
              repository = Repository.handle_push_event(@event)
            end.to change(PublicActivity::Activity, :count).by(1)
          end

          activity = PublicActivity::Activity.last
          expect(activity.key).to eq("repository.push")
          expect(activity.owner).to eq(user)
          expect(activity.recipient).to eq(repository.tags.find_by(name: tag_name))
          expect(activity.trackable).to eq(repository)
          expect(repository.tags.find_by(name: tag_name).author).to eq(user)
        end
      end

      context "re-tagging of a known image from one namespace to another" do
        let(:repository_namespaced_name) { "portus/busybox" }
        let(:admin) { create(:admin) }

        before :each do
          team_user = create(:team, owners: [admin])
          @ns = create(:namespace, name: "portus", team: team_user, registry: registry)
          create(:repository, name: "busybox", namespace: registry.global_namespace)
        end

        it "preserves the previous namespace" do
          event = @event
          event["target"]["repository"] = repository_namespaced_name
          event["target"]["url"] = get_url(repository_namespaced_name, tag_name)
          VCR.use_cassette("registry/get_image_manifest_another_webhook", record: :none) do
            Repository.handle_push_event(event)
          end

          repos = Repository.all.order("id ASC")
          expect(repos.count).to be(2)
          expect(repos.first.namespace.id).to be(registry.global_namespace.id)
          expect(repos.last.namespace.id).to be(@ns.id)
        end
      end
    end

    context "not global repository" do
      let(:namespace_name) { "suse" }
      let(:digest) { "digest" }

      before :each do
        name = "#{namespace_name}/#{repository_name}"

        @event = build(:raw_push_manifest_event).to_test_hash
        @event["target"]["repository"] = name
        @event["target"]["url"] = get_url(name, tag_name)
        @event["target"]["digest"] = digest
        @event["request"]["host"] = registry.hostname
        @event["actor"]["name"] = user.username
      end

      context "when the namespace is not known by Portus" do
        it "does not create the namespace" do
          repository = Repository.handle_push_event(@event)
          expect(repository).to be_nil
        end
      end

      context "when the namespace is known by Portus" do
        before :each do
          @namespace = create(:namespace, name: namespace_name, registry: registry)
        end

        it "should create repository and tag objects when the repository is unknown to portus" do
          repository = nil
          VCR.use_cassette("registry/get_image_manifest_namespaced_webhook", record: :none) do
            repository = Repository.handle_push_event(@event)
          end

          expect(repository).not_to be_nil
          expect(Repository.count).to eq 1
          expect(Repository.count).to eq 1
          expect(Tag.count).to eq 1

          expect(repository.namespace.name).to eq(namespace_name)
          expect(repository.name).to eq(repository_name)
          expect(repository.tags.count).to eq 1
          expect(repository.tags.first.name).to eq tag_name
          expect(repository.tags.first.digest).to eq digest
          expect(repository.tags.find_by(name: tag_name).author).to eq(user)
        end

        it "should create a new tag when the repository is already known to portus" do
          repository = create(:repository, name: repository_name, namespace: @namespace)
          repository.tags << Tag.new(name: "1.0.0")

          VCR.use_cassette("registry/get_image_manifest_namespaced_webhook", record: :none) do
            repository = Repository.handle_push_event(@event)
          end

          expect(repository).not_to be_nil
          expect(Repository.count).to eq 1
          expect(Repository.count).to eq 1
          expect(Tag.count).to eq 2

          expect(repository.namespace.name).to eq(namespace_name)
          expect(repository.name).to eq(repository_name)
          expect(repository.tags.count).to eq 2
          expect(repository.tags.map(&:name)).to include("1.0.0", tag_name)
          expect(repository.tags.find_by(name: tag_name).author).to eq(user)
        end
      end
    end
  end

  describe "create_or_update" do
    let!(:registry)    { create(:registry) }
    let!(:owner)       { create(:user) }
    let!(:portus)      { create(:user, username: "portus") }
    let!(:team)        { create(:team, owners: [owner]) }
    let!(:namespace)   { create(:namespace, team: team) }
    let!(:repo1)       { create(:repository, name: "repo1", namespace: namespace) }
    let!(:repo2)       { create(:repository, name: "repo2", namespace: namespace) }
    let!(:tag1)        { create(:tag, name: "tag1", repository: repo1) }
    let!(:tag2)        { create(:tag, name: "tag2", repository: repo2) }
    let!(:tag3)        { create(:tag, name: "tag3", repository: repo2) }

    it "adds and deletes tags accordingly" do
      # Removes the existing tag and adds two.
      repo = { "name" => "#{namespace.name}/repo1", "tags" => ["latest", "0.1"] }
      repo = Repository.create_or_update!(repo)
      expect(repo.id).to eq repo1.id
      expect(repo.tags.map(&:name).sort).to match_array(["0.1", "latest"])

      # Make sure that the portus user is set to be the author of the tags.
      authors = repo.tags.map(&:author).uniq
      expect(authors.count).to eq 1
      expect(authors.first).to be_portus

      # Just adds a new tag.
      repo = { "name" => "#{namespace.name}/repo2",
               "tags" => ["latest", tag2.name, tag3.name] }
      repo = Repository.create_or_update!(repo)
      expect(repo.id).to eq repo2.id
      ary = [tag2.name, tag3.name, "latest"].sort
      expect(repo.tags.map(&:name).sort).to match_array(ary)

      # Create repo and tags.
      repo = { "name" => "busybox", "tags" => ["latest", "0.1"] }
      repo = Repository.create_or_update!(repo)
      expect(repo.name).to eq "busybox"
      expect(repo.tags.map(&:name).sort).to match_array(["0.1", "latest"])

      # Trying to create a repo into an unknown namespace.
      repo = { "name" => "unknown/repo1", "tags" => ["latest", "0.1"] }
      expect(Repository.create_or_update!(repo)).to be_nil
    end

    it "dosnt remove tags of same name for different repo" do
      # create "latest" for repo1 and repo2
      event_one = { "name" => "#{namespace.name}/repo1", "tags" => ["latest"] }
      Repository.create_or_update!(event_one)
      event_two = { "name" => "#{namespace.name}/repo2", "tags" => ["latest"] }
      Repository.create_or_update!(event_two)

      # remove "latest" for repo2
      event_three = { "name" => "#{namespace.name}/repo2", "tags" => ["other"] }
      Repository.create_or_update!(event_three)

      expect(repo1.tags.pluck(:name)).to include("latest")
      expect(repo2.tags.pluck(:name)).not_to include("latest")
    end
  end
end
