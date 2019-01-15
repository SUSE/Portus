# frozen_string_literal: true

require "rails_helper"
require "portus/background/garbage_collector"

describe ::Portus::Background::GarbageCollector do
  let(:old_tag)    { (APP_CONFIG["delete"]["garbage_collector"]["older_than"].to_i + 10).days.ago }
  let(:recent_tag) { (APP_CONFIG["delete"]["garbage_collector"]["older_than"].to_i - 10).days.ago }

  before do
    APP_CONFIG["delete"]["garbage_collector"]["enabled"] = true
    APP_CONFIG["delete"]["garbage_collector"]["keep_latest"] = 0
  end

  it "returns the proper value for sleep_value" do
    expect(subject.sleep_value).to eq 60
  end

  it "should never be disabled after being enabled" do
    expect(subject.disable?).to be_falsey
  end

  it "returns the proper value for to_s" do
    expect(subject.to_s).to eq "Garbage collector"
  end

  describe "#enabled?" do
    it "is marked as enabled" do
      expect(subject.enabled?).to be_truthy
    end

    it "is marked as disabled" do
      APP_CONFIG["delete"]["garbage_collector"]["enabled"] = false
      expect(subject.enabled?).to be_falsey
    end
  end

  describe "#work?" do
    it "returns false if the feature is disabled entirely" do
      APP_CONFIG["delete"]["garbage_collector"]["enabled"] = false
      expect(subject.work?).to be_falsey
    end

    it "returns false if there are no tags matching the given expectations" do
      allow_any_instance_of(::Portus::Background::GarbageCollector).to(
        receive(:tags_to_be_collected).and_return([])
      )
      expect(subject.work?).to be_falsey
    end

    it "returns true if there are tags available to be updated" do
      allow_any_instance_of(::Portus::Background::GarbageCollector).to(
        receive(:tags_to_be_collected).and_return(["tag"])
      )
      expect(subject.work?).to be_truthy
    end
  end

  describe "#tags_to_be_collected" do
    let!(:registry)   { create(:registry, hostname: "registry.test.lan") }
    let!(:user)       { create(:admin) }
    let!(:repository) { create(:repository, namespace: registry.global_namespace, name: "repo") }

    it "returns an empty collection if there are no tags" do
      tags = subject.send(:tags_to_be_collected)
      expect(tags).to be_empty
    end

    it "ignores older tags if pulled recently" do
      create(:tag, name: "tag", repository: repository, updated_at: old_tag, pulled_at: recent_tag)
      tags = subject.send(:tags_to_be_collected)
      expect(tags).to be_empty
    end

    it "exists a tag but it's considered recent" do
      create(:tag, name: "tag", repository: repository, updated_at: recent_tag)
      tags = subject.send(:tags_to_be_collected)
      expect(tags).to be_empty
    end

    it "ignores tags which are marked" do
      create(:tag, name: "tag", repository: repository, updated_at: old_tag, marked: true)
      tags = subject.send(:tags_to_be_collected)
      expect(tags).to be_empty
    end

    it "exists a tag which is older than expected" do
      create(:tag, name: "tag", repository: repository, updated_at: old_tag)
      tags = subject.send(:tags_to_be_collected)
      expect(tags.size).to eq 1
    end

    it "exists a tag which is older than expected but the name does not match" do
      APP_CONFIG["delete"]["garbage_collector"]["tag"] = "build-\d+"

      create(:tag, name: "tag", repository: repository, updated_at: old_tag)
      tags = subject.send(:tags_to_be_collected)
      expect(tags.size).to eq 0
    end

    it "exists a tag which is older and with a proper name" do
      APP_CONFIG["delete"]["garbage_collector"]["tag"] = "^build-\\d+$"

      create(:tag, name: "build-1234", repository: repository, updated_at: old_tag)
      tags = subject.send(:tags_to_be_collected)
      expect(tags.size).to eq 1
    end
  end

  describe "#execute!" do
    let!(:registry)   { create(:registry, hostname: "registry.test.lan") }
    let!(:repository) { create(:repository, namespace: registry.global_namespace, name: "repo") }

    before { User.create_portus_user! }

    it "removes tags" do
      allow_any_instance_of(Tag).to(receive(:fetch_digest).and_return("1234"))
      allow_any_instance_of(::Portus::RegistryClient).to(receive(:delete).and_return(true))

      create(:tag, name: "tag", digest: "1234", repository: repository, updated_at: old_tag)
      expect do
        subject.execute!
      end.to(change { Tag.all.count }.from(1).to(0))
    end

    it "skips older tags if number of tags < keep_latest" do
      APP_CONFIG["delete"]["garbage_collector"]["keep_latest"] = 5
      create_list(:tag, 4, repository: repository, updated_at: old_tag)

      expect { subject.execute! }.not_to change(Tag.all, :count)
    end

    it "skips older tags if it was pulled recently" do
      create_list(:tag, 4, repository: repository, updated_at: old_tag, pulled_at: recent_tag)

      expect { subject.execute! }.not_to change(Tag.all, :count)
    end

    it "skips tags which could not be removed for whatever reason" do
      allow_any_instance_of(Tag).to(
        receive(:fetch_digest) { |tag| tag.digest == "wrong" ? "" : tag.digest }
      )
      allow_any_instance_of(::Portus::RegistryClient).to(receive(:delete).and_return(true))

      expect(Rails.logger).to(receive(:warn).with("Could not remove <strong>tag2</strong> tag"))

      create(:tag, name: "tag1", digest: "1234", repository: repository, updated_at: old_tag)
      create(:tag, name: "tag2", digest: "wrong", repository: repository, updated_at: old_tag)
      expect { subject.execute! }.to(change { Tag.all.count }.from(2).to(1))
    end
  end
end
