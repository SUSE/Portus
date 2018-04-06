# frozen_string_literal: true

require "rails_helper"
require "portus/security"

def expect_cve_match(cves, given, expected)
  cves.each do |cve|
    r = given.find { |x| x["Name"] == cve }
    e = expected.find { |x| x["Name"] == cve }

    expect(r).to include(e)
  end
end

describe ::Portus::SecurityBackend::Clair do
  before do
    APP_CONFIG["security"] = {
      "clair" => {
        "server"  => "http://my.clair:6060",
        "timeout" => 900
      }, "zypper" => {
        "server" => ""
      }, "dummy" => {
        "server" => ""
      }
    }
  end

  let!(:reg) do
    create(
      :registry,
      name:     "registry",
      hostname: "registry.test.cat:5000",
      use_ssl:  true
    )
  end

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

  it "returns CVEs successfully" do
    VCR.turn_on!
    res = {}

    VCR.use_cassette("security/clair", record: :none) do
      clair = ::Portus::Security.new("coreos/dex", "unrelated")
      res = clair.vulnerabilities
    end

    expect_cve_match(["CVE-2016-6301", "CVE-2016-8859"], res[:clair], proper[:clair])
  end

  it "returns no CVEs if 'Features' is nil" do
    VCR.turn_on!
    res = {}

    VCR.use_cassette("security/clair_features_nil", record: :none) do
      clair = ::Portus::Security.new("coreos/dex", "unrelated")
      res = clair.vulnerabilities
    end

    expect(res[:clair]).to be_empty
  end

  it "returns an empty array when posting is unsuccessful" do
    VCR.turn_on!
    res = {}

    VCR.use_cassette("security/clair-wrong-post", record: :none) do
      clair = ::Portus::Security.new("coreos/dex", "unrelated")
      res = clair.vulnerabilities
    end

    expect(res[:clair]).to be_empty
  end

  it "returns an empty array when fetching is unsuccessful" do
    VCR.turn_on!
    res = {}

    VCR.use_cassette("security/clair-wrong-get", record: :none) do
      clair = ::Portus::Security.new("coreos/dex", "unrelated")
      res = clair.vulnerabilities
    end

    expect(res[:clair]).to be_empty
  end

  it "returns an empty array if clair is not accessible" do
    APP_CONFIG["security"]["clair"]["server"] = "http://localhost:6060"

    VCR.turn_on!
    res = {}

    VCR.use_cassette("security/clair-is-not-there", record: :none) do
      clair = ::Portus::Security.new("coreos/dex", "unrelated")
      res = clair.vulnerabilities
    end

    expect(res[:clair]).to be_empty
  end

  it "returns an empty array if clair is unknown" do
    VCR.turn_on!
    res = {}

    # Digest as returned by the VCR tape.
    digest = "sha256:28c417e954d8f9d2439d5b9c7ea3dcb2fd31690bf2d79b94333d889ea26689d2"

    # Unfortunately VCR is not good with requests that are meant to time
    # out. For this, then, we will manually stub requests so they raise the
    # expected error on this situation.
    stub_request(:post, "http://my.clair:6060/v1/layers").to_raise(Errno::ECONNREFUSED)
    stub_request(:get, "http://my.clair:6060/v1/layers/#{digest}?" \
                       "features=false&vulnerabilities=true").to_raise(Errno::ECONNREFUSED)

    VCR.use_cassette("security/clair-is-unknown", record: :none) do
      clair = ::Portus::Security.new("coreos/dex", "unrelated")
      res = clair.vulnerabilities
    end

    expect(res[:clair]).to be_empty
  end

  it "does not raise an exception for timeouts on post" do
    VCR.turn_on!
    res = {}

    # Digest as returned by the VCR tape.
    digest = "sha256:28c417e954d8f9d2439d5b9c7ea3dcb2fd31690bf2d79b94333d889ea26689d2"

    # Unfortunately VCR is not good with requests that are meant to time
    # out. For this, then, we will manually stub requests so they raise the
    # expected error on this situation.
    stub_request(:post, "http://my.clair:6060/v1/layers").to_raise(Net::ReadTimeout)
    stub_request(:get, "http://my.clair:6060/v1/layers/#{digest}?" \
                       "features=false&vulnerabilities=true").to_raise(Errno::ECONNREFUSED)

    VCR.use_cassette("security/clair-is-unknown", record: :none) do
      clair = ::Portus::Security.new("coreos/dex", "unrelated")
      res = clair.vulnerabilities
    end

    expect(res[:clair]).to be_empty
  end

  it "returns nil when a timeout occurred when fetching the manifest" do
    allow_any_instance_of(::Portus::RegistryClient).to receive(:manifest)
      .and_raise(::Portus::RequestError, exception: Net::ReadTimeout, message: "something")

    clair = ::Portus::Security.new("coreos/dex", "unrelated")
    expect(clair.vulnerabilities).to be_nil
  end

  it "returns nil when the manifest does not exist anymore on the registry" do
    allow_any_instance_of(::Portus::RegistryClient).to receive(:manifest)
      .and_raise(::Portus::Errors::NotFoundError, "something")

    clair = ::Portus::Security.new("coreos/dex", "unrelated")
    expect(clair.vulnerabilities).to be_nil
  end

  it "returns nil when there was something wrong with the manifest" do
    allow_any_instance_of(::Portus::RegistryClient).to receive(:manifest)
      .and_raise(::Portus::RegistryClient::ManifestError, "something")

    clair = ::Portus::Security.new("coreos/dex", "unrelated")
    expect(clair.vulnerabilities).to be_nil
  end
end
