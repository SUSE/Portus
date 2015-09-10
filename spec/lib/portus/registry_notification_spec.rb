require "rails_helper"

describe Portus::RegistryNotification do
  let(:body) do
    {
      "events" => [
        { "action" => "push" },
        { "action" => "push", "target" => { "mediaType" => "some" } },
        {
          "action" => "pull", "target" => {
            "mediaType" => "application/vnd.docker.distribution.manifest.v1+json"
          }
        }
      ]
    }
  end

  let(:relevant) do
    {
      "action" => "push",
      "target" => {
        "mediaType"  => "application/vnd.docker.distribution.manifest.v1+json",
        "digest"     => "sha256:1977980aad73e19f918c676de1860b0ee56167b07c20641ecda3f9d74b69627d",
        "repository" => "mssola/busybox",
        "url"        => "http://registry.test.lan/v2/mssola/busybox/manifests/sha256:1977980aad7"
      }
    }
  end

  it "processes all the relevant events" do
    body["events"] << relevant
    expect(Repository).to receive(:handle_push_event).with(relevant)
    Portus::RegistryNotification.process!(body, Repository)
  end
end
