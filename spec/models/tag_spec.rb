# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id            :integer          not null, primary key
#  name          :string(255)      default("latest"), not null
#  repository_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :integer
#  digest        :string(255)
#  image_id      :string(255)      default("")
#  marked        :boolean          default(FALSE)
#  username      :string(255)
#  scanned       :integer          default(0)
#  size          :bigint(8)
#  pulled_at     :datetime
#
# Indexes
#
#  index_tags_on_repository_id  (repository_id)
#  index_tags_on_user_id        (user_id)
#

require "rails_helper"

# Mock class that opens up the `fetch_digest` method as `fetch_digest_test` so
# it can be properly unit tested.
class TagMock < Tag
  def fetch_digest_test
    fetch_digest
  end
end

describe Tag do
  let!(:registry)    { create(:registry, hostname: "registry.test.lan") }
  let!(:user)        { create(:admin) }
  let!(:repository)  { create(:repository, namespace: registry.global_namespace, name: "repo") }
  let!(:repository1) { create(:repository, namespace: registry.global_namespace, name: "repo1") }

  it { is_expected.to belong_to(:repository) }
  it { is_expected.to belong_to(:author) }

  describe "creating tags" do
    it "defaults to latest" do
      t = described_class.create(repository: repository)
      expect(t.name).to eq("latest")
    end

    it "does not accept nil names" do
      expect do
        described_class.create(name: nil, repository: repository)
      end.to raise_error(ActiveRecord::StatementInvalid)
    end

    it "validates the uniqueness" do
      create(:tag, name: "tag", repository: repository)
      expect do
        create(:tag, name: "tag", repository: repository)
      end.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "case sensitive for tag names" do
      create(:tag, name: "tag", repository: repository)
      expect do
        create(:tag, name: "TAG", repository: repository)
      end.not_to raise_error
    end
  end

  describe "#delete_by_digest!" do
    let!(:tag)  { create(:tag, name: "tag1", repository: repository, digest: "1") }
    let!(:tag2) { create(:tag, name: "tag2", repository: repository, digest: "2") }
    let!(:tag3) { create(:tag, name: "tag3", repository: repository1, digest: "2") }

    it "returns false if there is no digest" do
      allow_any_instance_of(described_class).to receive(:fetch_digest).and_return(nil)
      expect(tag.delete_by_digest!(user)).to be_falsey
    end

    it "returns false if the registry client could not delete the tag" do
      allow_any_instance_of(Portus::RegistryClient).to receive(:delete) do
        raise ::Portus::RegistryClient::RegistryError, "I AM ERROR."
      end

      # That being said, the tag should be "marked".
      expect(tag.delete_by_digest!(user)).to be_falsey
      expect(tag.reload).to be_marked
    end

    it "deletes the tag and updates corresponding activities" do
      # Create push activities. This is important so we can test afterwards
      # that they will get updated on removal.
      repository.create_activity(:push, owner: user, recipient: tag)
      repository.create_activity(:push, owner: user, recipient: tag2)

      tag.delete_by!(user)

      activities = PublicActivity::Activity.order(:updated_at)
      expect(activities.count).to eq 3

      # The first activity is the first push, which should've changed.
      activity = activities.first
      expect(activity.trackable_type).to eq "Repository"
      expect(activity.trackable_id).to eq repository.id
      expect(activity.owner_id).to eq user.id
      expect(activity.key).to eq "repository.push"
      expect(activity.parameters).to eq(namespace_id:   registry.global_namespace.id,
                                        namespace_name: registry.global_namespace.clean_name,
                                        repo_name:      repository.name,
                                        tag_name:       tag.name)

      # The second activity is the other push, which is unaffected by this
      # action.
      activity = activities[1]
      expect(activity.trackable_type).to eq "Repository"
      expect(activity.trackable_id).to eq repository.id
      expect(activity.owner_id).to eq user.id
      expect(activity.key).to eq "repository.push"
      expect(activity.parameters).to be_empty

      # The last activity is the removal of the tag.
      activity = activities.last
      expect(activity.trackable_type).to eq "Repository"
      expect(activity.trackable_id).to eq repository.id
      expect(activity.owner_id).to eq user.id
      expect(activity.key).to eq "repository.delete"
      expect(activity.parameters).to eq(namespace_id:    registry.global_namespace.id,
                                        namespace_name:  registry.global_namespace.clean_name,
                                        repository_name: repository.name,
                                        tag_name:        tag.name)
    end

    it "calls the registry with the right parameters if digest is blank" do
      team = create(:team)
      namespace = create(:namespace, name: "a", team: team, registry: registry)
      repo = create(:repository, name: "repo", namespace: namespace)
      tag = create(:tag, name: "t", repository: repo)
      manifest = OpenStruct.new(id: nil, digest: "digest", size: nil, manifest: nil)

      allow_any_instance_of(Portus::RegistryClient).to(
        receive(:manifest)
          .with(repo.full_name, tag.name)
          .and_return(manifest)
      )
      allow_any_instance_of(Portus::RegistryClient).to(
        receive(:delete)
          .with(repo.full_name, "digest", "manifests")
          .and_return(true)
      )

      tag.delete_by_digest!(user)

      expect(described_class.find_by(name: "t")).to be_nil
    end

    it "does not remove tags from other repositories" do
      allow_any_instance_of(Tag).to receive(:fetch_digest).and_return("2")
      allow_any_instance_of(Portus::RegistryClient).to(
        receive(:delete)
          .with(repository.full_name, "2", "manifests")
          .and_return(true)
      )

      tag2.delete_by_digest!(user)

      expect(repository.tags.count).to eq 1
      expect(repository1.tags.count).to eq 1
    end
  end

  # NOTE: lots of cases are being left out on purpose because they are already
  # tested in the previous `describe` block.
  describe "#delete_by!" do
    let!(:tag) { create(:tag, name: "tag1", repository: repository, digest: "1") }

    before do
      tag.destroy
    end

    it "does nothing if the tag has already beed removed" do
      expect(Rails.logger).to receive(:info).with(/Removed the tag.../)
      expect(Rails.logger).to receive(:info).with(/Ignoring.../)
      tag.delete_by!(user)
    end
  end

  describe "#fetch_digest" do
    it "returns the digest as-is if it's not empty" do
      tag = TagMock.create(name: "tag", repository: repository, digest: "1")
      expect(tag.fetch_digest_test).to eq tag.digest
    end

    it "returns the digest as given by the registry" do
      manifest = OpenStruct.new(id: "id", digest: "2", size: nil, manifest: "")
      allow_any_instance_of(Portus::RegistryClient).to receive(:manifest).and_return(manifest)

      tag = TagMock.create(name: "tag", repository: repository)
      expect(tag.fetch_digest_test).to eq "2"
    end

    it "returns nil if the client could not fetch the digest" do
      allow_any_instance_of(Portus::RegistryClient).to receive(:manifest) do
        raise ::Portus::RegistryClient::ManifestError, "I AM ERROR."
      end

      tag = TagMock.create(name: "tag", repository: repository)
      expect(tag.fetch_digest_test).to be_nil
    end
  end

  describe "#owner" do
    let!(:tag) { create(:tag, name: "tag1", user_id: user.id, repository: repository, digest: "1") }

    it "returns the proper owner" do
      expect(tag.owner).to eq user.display_username
      tag.user_id = nil
      expect(tag.owner).to eq "someone"
      tag.username = "user"
      expect(tag.owner).to eq "user"
    end
  end

  describe "#fetch_vulnerabilities" do
    let!(:tag) { create(:tag, name: "tag", user_id: user.id, repository: repository, digest: "1") }
    let!(:vulnerability) { create(:vulnerability, name: "CVE-1234", scanner: "clair") }
    let!(:scan_result)   { create(:scan_result, tag: tag, vulnerability: vulnerability) }

    it "returns nil if security scanning is not enabled" do
      # Checking that even if scanning is done and there are vulnerabilities, it
      # returns nil because security scanning is disabled.
      tag.update_columns(scanned: described_class.statuses[:scan_done])
      expect(tag.fetch_vulnerabilities).to be_nil
    end

    it "returns nil if scan has not started" do
      enable_security_vulns_module!
      expect(tag.fetch_vulnerabilities).to be_nil
    end

    it "returns nil if scan is work in progress" do
      enable_security_vulns_module!
      tag.update_columns(scanned: described_class.statuses[:scan_working])
      expect(tag.fetch_vulnerabilities).to be_nil
    end

    it "returns the vulnerabilities when scan is over" do
      enable_security_vulns_module!
      tag.update_columns(scanned: described_class.statuses[:scan_done])
      expect(tag.fetch_vulnerabilities).to eq [vulnerability]
    end
  end
end
