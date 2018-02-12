# frozen_string_literal: true

require "rails_helper"
require "portus/background/security_scanning"

describe ::Portus::Background::SecurityScanning do
  let!(:admin) { create(:admin) }
  let!(:token) { create(:application_token, user: admin) }
  let!(:registry)   { create(:registry, hostname: "my.registry:5000", use_ssl: true) }
  let!(:repository) { create(:repository, name: "repo", namespace: registry.global_namespace) }

  before do
    APP_CONFIG["security"] = {
      "clair"  => { "server" => "http://localhost:6060" },
      "zypper" => { "server" => "" },
      "dummy"  => { "server" => "" }
    }
  end

  describe "#sleep_value" do
    it "returns always 10" do
      expect(subject.sleep_value).to eq 10
    end
  end

  describe "#work?" do
    it "returns false if security scanning is not enabled" do
      APP_CONFIG["security"]["clair"]["server"] = ""
      expect(subject).not_to be_work
    end

    it "returns true if there are tags to be scanned" do
      create(:tag, name: "tag", repository: repository, digest: "1", author: admin)
      expect(subject).to be_work
    end

    it "returns false if no tags are to be scanned" do
      create(:tag, name: "tag", repository: repository, digest: "1",
             author: admin, scanned: Tag.statuses[:scan_done])
      expect(subject).not_to be_work
    end
  end

  describe "#execute!" do
    it "properly saves the vulnerabilities" do
      VCR.turn_on!

      tag = create(:tag, name: "tag", repository: repository, author: admin)

      VCR.use_cassette("background/clair", record: :none) do
        subject.execute!
      end

      tag.reload
      expect(tag.scanned).to eq Tag.statuses[:scan_done]
      expect(tag.vulnerabilities).not_to be_empty
    end

    it "ignores it when a push has happened while fetching vulnerabilities" do
      tag = create(:tag, name: "tag", repository: repository, digest: "1", author: admin)

      allow_any_instance_of(::Portus::Security).to receive(:vulnerabilities) do
        tag.reload
        expect(tag.scanned).to eq Tag.statuses[:scan_working]

        # Faking a push
        Tag.update_all(scanned: Tag.statuses[:scan_none])
        []
      end

      subject.execute!

      tag.reload
      expect(tag.scanned).to eq Tag.statuses[:scan_none]
    end

    it "ignores it when a delete has happened while fetching vulnerabilities" do
      tag = create(:tag, name: "tag", repository: repository, digest: "1", author: admin)

      allow_any_instance_of(::Portus::Security).to receive(:vulnerabilities) do |_, *_args|
        tag.reload
        expect(tag.scanned).to eq Tag.statuses[:scan_working]

        # Faking a delete
        Tag.delete_all
        []
      end

      subject.execute!
      expect { tag.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "updates all tags with the same digest" do
      tag   = create(:tag, name: "tag", repository: repository, digest: "1", author: admin)
      tag1  = create(:tag, name: "tag1", repository: repository, digest: "1", author: admin)
      count = 0

      allow_any_instance_of(::Portus::Security).to receive(:vulnerabilities) do
        count += 1

        tag.reload
        tag1.reload
        expect(tag.scanned).to eq Tag.statuses[:scan_working]
        expect(tag1.scanned).to eq Tag.statuses[:scan_working]
        ["something"]
      end

      subject.execute!

      expect(count).to eq 1
      expect(Tag.all).to(be_all { |t| t.scanned == Tag.statuses[:scan_done] })
      expect(Tag.all).to(be_all { |t| t.vulnerabilities == ["something"] })
    end

    it "marks tags as not scanned if it does not fetch vulnerabilities properly" do
      create(:tag, name: "tag", repository: repository, digest: "1", author: admin)
      allow_any_instance_of(::Portus::Security).to receive(:vulnerabilities) {}
      allow_any_instance_of(Tag).to receive(:update_vulnerabilities) {}

      subject.execute!

      t = Tag.find_by(name: "tag")
      expect(t.scanned).to eq(Tag.statuses[:scan_none])
    end
  end

  describe "#to_s" do
    it "works" do
      expect(subject.to_s).to eq "Security scanning"
    end
  end
end
