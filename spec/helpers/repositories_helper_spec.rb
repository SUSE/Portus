require "rails_helper"

class CatalogJobMock < CatalogJob
  def update_registry!(catalog)
    super
  end
end

RSpec.describe RepositoriesHelper, type: :helper do
  describe "#can_trigger_build?" do
    let(:registry) { create(:registry) }
    let(:owner) { create(:user) }
    let(:contributor) { create(:user) }
    let(:viewer) { create(:user) }
    let(:external) { create(:user) }
    let(:team) { create(:team, owners: [owner], contributors: [contributor], viewers: [viewer]) }
    let(:namespace) { create(:namespace, team: team) }
    let(:repo) { create(:repository, namespace: namespace, source_url: "git.example.com/foo.git") }

    context "navalia disabled" do
      before :each do
        APP_CONFIG["navalia"] = { "enabled" => false }
      end

      it "returns false" do
        admin = create(:user, admin: true)
        sign_in admin

        expect(helper.can_trigger_build?(repo)).not_to be true
      end
    end

    context "not automated repository" do
      before :each do
        APP_CONFIG["navalia"] = { "enabled" => true }
      end

      it "returns false" do
        repo = create(:repository, namespace: namespace, source_url: "")
        admin = create(:user, admin: true)
        sign_in admin

        expect(helper.can_trigger_build?(repo)).not_to be true
      end
    end

    context "navalia enabled" do
      before :each do
        APP_CONFIG["navalia"] = { "enabled" => true }
      end

      it "returns true if the user is an admin" do
        admin = create(:user, admin: true)
        sign_in admin

        expect(helper.can_trigger_build?(repo)).to be true
      end

      it "returns true if the user is an owner" do
        sign_in owner

        expect(helper.can_trigger_build?(repo)).to be true
      end

      it "returns true if the user is a contributor" do
        sign_in contributor

        expect(helper.can_trigger_build?(repo)).to be true
      end

      it "returns false if the user is a viewer" do
        sign_in viewer

        expect(helper.can_trigger_build?(repo)).not_to be true
      end

      it "returns false if the user has not relation with the repository" do
        sign_in external

        expect(helper.can_trigger_build?(repo)).not_to be true
      end
    end

  end

  describe "#render_push_activity" do
    let!(:registry)   { create(:registry, hostname: "registry:5000") }
    let!(:namespace)  { create(:namespace, name: "namespace", registry: registry) }
    let!(:owner)      { create(:user) }
    let!(:repo)       { create(:repository, name: "repo", namespace: registry.global_namespace) }
    let!(:repo1)      { create(:repository, name: "repo1", namespace: registry.global_namespace) }
    let!(:repo2)      { create(:repository, name: "repo2", namespace: registry.global_namespace) }
    let!(:repo3)      { create(:repository, name: "repo3", namespace: namespace) }
    let!(:tag)        { create(:tag, name: "latest", author: owner, repository: repo) }
    let!(:tag1)       { create(:tag, name: "0.1", author: owner, repository: repo) }
    let!(:tag2)       { create(:tag, name: "0.2", author: owner, repository: repo1) }
    let!(:tag3)       { create(:tag, name: "0.3", author: owner, repository: repo2) }
    let!(:tag4)       { create(:tag, name: "0.4", author: owner, repository: repo3) }

    it "creates the proper HTML for each kind of activity" do
      repo.create_activity(:push, owner: owner, recipient: tag)
      repo.create_activity(:push, owner: owner, recipient: tag1)
      repo1.create_activity(:push, owner: owner, recipient: tag2)
      repo2.create_activity(:push, owner: owner, recipient: tag3)
      repo3.create_activity(:push, owner: owner, recipient: tag4)

      tag1.destroy
      repo1.destroy

      nameo  = owner.username
      global = registry.global_namespace.id

      # rubocop:disable Metrics/LineLength
      expectations = [
        "<strong>#{nameo} pushed </strong><a href=\"/namespaces/#{global}\">registry:5000</a> / <a href=\"/repositories/#{repo.id}\">repo:latest</a>",
        "<strong>#{nameo} pushed </strong><a href=\"/namespaces/#{global}\">registry:5000</a> / <a href=\"/repositories/#{repo.id}\">repo</a>",
        "<strong>#{nameo} pushed </strong><span>a repository</span>",
        "<strong>#{nameo} pushed </strong><a href=\"/namespaces/#{global}\">registry:5000</a> / <a href=\"/repositories/#{repo2.id}\">repo2:0.3</a>",
        "<strong>#{nameo} pushed </strong><a href=\"/namespaces/#{namespace.id}\">namespace</a> / <a href=\"/repositories/#{repo3.id}\">repo3:0.4</a>"
      ]
      # rubocop:enable Metrics/LineLength

      idx = 0
      PublicActivity::Activity.all.order(created_at: :desc).each do |activity|
        html = render_push_activity(activity)
        expect(html).to eq expectations[idx]
        idx += 1
      end

      # And now the catalog job sweeps in.
      job = CatalogJobMock.new
      job.update_registry!([{ "name" => "repo", "tags" => ["0.1"] }])

      # Let's remove the other namespace, to force another case.
      namespace.destroy

      idx = 0

      # Changes because of the Catalog job.
      # rubocop:disable Metrics/LineLength
      expectations[3] = "<strong>#{nameo} pushed </strong><a href=\"/namespaces/#{global}\">registry:5000</a> / <a href=\"/namespaces/#{global}\">repo2:0.3</a>"
      expectations[4] = "<strong>#{nameo} pushed </strong><span>namespace</span> / <span>repo3:0.4</span>"
      # rubocop:enable Metrics/LineLength

      PublicActivity::Activity.all.order(created_at: :desc).each do |activity|
        html = render_push_activity(activity)
        expect(html).to eq expectations[idx]
        idx += 1
      end
    end

    describe "render edit activity" do
      let!(:registry)   { create(:registry, hostname: "registry:5000") }
      let!(:namespace)  { create(:namespace, name: "namespace", registry: registry) }
      let!(:owner)      { create(:user) }
      let!(:repo)       { create(:repository, name: "repo", namespace: namespace) }

      it "works when the new source is empty" do
        repo.create_activity(
          :edit,
          owner:      owner,
          parameters: { old_source: "old", new_source: "" })

        html = render_edit_activity(PublicActivity::Activity.last)
        expect(html).to eq(
          "<strong>#{owner.username} edited </strong>" \
          "<a href=\"/namespaces/#{namespace.id}\">#{namespace.name}</a>" \
          " / <a href=\"/repositories/#{repo.id}\">repo</a>" \
          " making it a non-automated repository"
        )
      end

      it "works when all the sources are not empty" do
        repo.create_activity(
          :edit,
          owner:      owner,
          parameters: { old_source: "old", new_source: "new" })

        html = render_edit_activity(PublicActivity::Activity.last)
        expect(html).to eq(
          "<strong>#{owner.username} edited </strong>" \
          "<a href=\"/namespaces/#{namespace.id}\">#{namespace.name}</a>" \
          " / <a href=\"/repositories/#{repo.id}\">repo</a>" \
          " changing source URL from <code>old</code> to <code>new</code>"
        )
      end

      it "works when the old source is empty" do
        repo.create_activity(
          :edit,
          owner:      owner,
          parameters: { old_source: "", new_source: "new" })

        html = render_edit_activity(PublicActivity::Activity.last)
        expect(html).to eq(
          "<strong>#{owner.username} edited </strong>" \
          "<a href=\"/namespaces/#{namespace.id}\">#{namespace.name}</a>" \
          " / <a href=\"/repositories/#{repo.id}\">repo</a>" \
          " set source URL to <code>new</code>"
        )
      end

      it "works when the new source is empty" do
        repo.create_activity(
          :edit,
          owner:      owner,
          parameters: { old_source: "old", new_source: "" })

        html = render_edit_activity(PublicActivity::Activity.last)
        expect(html).to eq(
          "<strong>#{owner.username} edited </strong>" \
          "<a href=\"/namespaces/#{namespace.id}\">#{namespace.name}</a>" \
          " / <a href=\"/repositories/#{repo.id}\">repo</a>" \
          " making it a non-automated repository"
        )
      end

      it "works when all the sources are not empty" do
        repo.create_activity(
          :edit,
          owner:      owner,
          parameters: { old_source: "old", new_source: "new" })

        html = render_edit_activity(PublicActivity::Activity.last)
        expect(html).to eq(
          "<strong>#{owner.username} edited </strong>" \
          "<a href=\"/namespaces/#{namespace.id}\">#{namespace.name}</a>" \
          " / <a href=\"/repositories/#{repo.id}\">repo</a>" \
          " changing source URL from <code>old</code> to <code>new</code>"
        )
      end
    end

    describe "render create activity" do
      let!(:registry)   { create(:registry, hostname: "registry:5000") }
      let!(:namespace)  { create(:namespace, name: "namespace", registry: registry) }
      let!(:owner)      { create(:user) }
      let!(:repo)       { create(:repository, name: "repo", namespace: namespace) }

      it "works as expected" do
        repo.create_activity(
          :create,
          owner:      owner,
          parameters: { source_url: "git" })

        html = render_create_activity(PublicActivity::Activity.last)
        expect(html).to eq(
          "<strong>#{owner.username} created </strong>" \
          "<a href=\"/namespaces/#{namespace.id}\">#{namespace.name}</a>" \
          " / <a href=\"/repositories/#{repo.id}\">repo</a>" \
          " with source URL set to <code>git</code>"
        )
      end
    end

  end
end
