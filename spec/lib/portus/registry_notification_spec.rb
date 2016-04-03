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

  # This is a real even notification as given by docker distribution v2.3
  # rubocop:disable Metrics/LineLength
  let(:version23) do
    {
      "id"        => "7dc1c55c-dfe2-4699-ab0b-8f32e89882ce",
      "timestamp" => "2016-02-05T11:16:14.917994087+01:00",
      "action"    => "push",
      "target"    => {
        "mediaType"  => "application/vnd.docker.distribution.manifest.v1+prettyjws",
        "size"       => 2739,
        "digest"     => "sha256:b9c8a3839b2754e0fc4309e0f994f617d43814996805388e2f9d977db3fa7967",
        "length"     => 2739,
        "repository" => "mssola/lala",
        "url"        => "https://registry.mssola.cat:5000/v2/mssola/lala/manifests/sha256:b9c8a3839b2754e0fc4309e0f994f617d43814996805388e2f9d977db3fa7967"
      },
      "request"   => {
        "id"        => "e30471d8-39c3-41c0-abc2-775ed43e81c9",
        "addr"      => "127.0.0.1:54032",
        "host"      => "registry.mssola.cat:5000",
        "method"    => "PUT",
        "useragent" => "docker/1.9.1 go/go1.5.2 git-commit/a34a1d5 kernel/4.4.0-1-default os/linux arch/amd64"
      },
      "actor"     => {
        "name" => "mssola"
      },
      "source"    => {
        "addr"       => "g67:5000",
        "instanceID" => "18771ece-0887-40f8-ad53-ee46451b4d8b"
      }
    }
  end
  # rubocop:enable Metrics/LineLength

  it "processes all the relevant events" do
    body["events"] << relevant
    body["events"] << version23
    expect(Repository).to receive(:handle_push_event).with(relevant)
    expect(Repository).to receive(:handle_push_event).with(version23)
    Portus::RegistryNotification.process!(body, Repository)
  end
end
