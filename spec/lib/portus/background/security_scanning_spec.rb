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
      "clair"  => {
        "server"  => "http://my.clair:6060",
        "timeout" => 900
      },
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
    let!(:repository2) { create(:repository, name: "node", namespace: registry.global_namespace) }
    let(:proper) do
      {
        clair: [
          {
            "Name"          => "CVE-2016-8859",
            "NamespaceName" => "alpine:v3.4",
            "Link"          => "https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2016-8859",
            "Severity"      => "High",
            "FixedBy"       => "1.1.14-r13"
          },
          {
            "Name"          => "CVE-2016-6301",
            "NamespaceName" => "alpine:v3.4",
            "Link"          => "https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2016-6301",
            "Severity"      => "High",
            "FixedBy"       => "1.24.2-r12"
          }
        ]
      }.freeze
    end

    it "saves all data" do
      # Data from the real image `node:8`
      create(
        :tag,
        name:       "8",
        user_id:    admin.id,
        repository: repository2,
        digest:     "sha256:021c1dba94d141972a13f62194fea0f8ef2a081cd9c03fd3f70a529886a8af11",
        image_id:   "b87c2ad8344dd1c1fdfd09060a99ff5dbac4a1fe1a079ad871dfa228fc628e1c"
      )

      VCR.turn_on!
      VCR.use_cassette("background/node", record: :none) do
        subject.execute!
      end

      vul = Vulnerability.all.order(:id).first
      expect(vul.name).to eq "CVE-2004-0230"
      expect(vul.scanner).to eq "clair"
      expect(vul.severity).to eq "Negligible"
      expect(vul.link).not_to be_empty
      expect(vul.metadata).not_to be_empty
      expect(vul.description).not_to be_empty

      # There's at least one vulnerability with the "FixedBy" attribute.
      expect(Vulnerability.all.any? { |v| v.fixed_by.present? }).to be_truthy
    end

    it "properly saves the vulnerabilities" do
      VCR.turn_on!

      tag = create(:tag, name: "tag", repository: repository, author: admin)

      VCR.use_cassette("background/clair", record: :none) do
        subject.execute!
      end

      tag.reload
      expect(tag.scanned).to eq Tag.statuses[:scan_done]
      expect(tag.vulnerabilities.size).to eq 11
      expect(tag.vulnerabilities.order(:id).first.name).to eq "CVE-2016-6301"
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
        proper
      end

      subject.execute!

      expect(count).to eq 1
      expect(Tag.all).to(be_all { |t| t.scanned == Tag.statuses[:scan_done] })
      expect(Tag.all).to(be_all { |t| t.vulnerabilities.size == 2 })
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

  describe "#enabled?" do
    it "returns true when enabled" do
      expect(subject.enabled?).to be_truthy
    end

    it "returns false when not enabled" do
      APP_CONFIG["security"] = {
        "clair"  => { "server" => "" },
        "zypper" => { "server" => "" },
        "dummy"  => { "server" => "" }
      }
      expect(subject.enabled?).to be_falsey
    end
  end

  describe "#disable?" do
    it "always returns false" do
      expect(subject.disable?).to be_falsey
    end
  end

  describe "#to_s" do
    it "works" do
      expect(subject.to_s).to eq "Security scanning"
    end
  end
end
