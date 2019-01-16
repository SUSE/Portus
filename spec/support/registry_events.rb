# frozen_string_literal: true

module Portus
  module Fixtures
    # Shared fixture data dealing with registry events.
    module RegistryEvent
      SHA = "sha256:b9c8a3839b2754e0fc4309e0f994f617d43814996805388e2f9d977db3fa7967"

      BODY =
        {
          "events" => [
            { "action" => "push" },
            { "action" => "push", "target" => { "mediaType" => "some" } },
            {
              "action" => "irrelevant",
              "target" => {
                "mediaType" => "application/vnd.docker.distribution.manifest.v2+json"
              }
            }
          ]
        }.freeze

      PULL =
        {
          "id"        => "847f45bb-5f19-4c1b-b198-6c5ba467c127",
          "timestamp" => "2019-01-15T20:17:10.595087128Z",
          "action"    => "pull",
          "target"    => {
            "mediaType"  => "application/vnd.docker.distribution.manifest.v2+json",
            "size"       => 2193,
            "digest"     => "sha256:095ca87493f6a2147b8543a669f2d773097df9be7e17a981033c",
            "length"     => 2193,
            "repository" => "vitoravelino/etcd",
            "tag"        => "v3.2.25-arm64"
          },
          "actor"     => {
            "name" => "vitoravelino"
          },
          "source"    => {
            "addr"       => "50549da63cc2:5000",
            "instanceID" => "a481f8c8-a71c-4395-b90c-f8d32a083d02"
          }
        }.freeze

      RELEVANT =
        {
          "id"     => "5d673710-06b5-48b5-a7d9-94cbaacf776b",
          "action" => "push",
          "target" => {
            "mediaType"  => "application/vnd.docker.distribution.manifest.v1+json",
            "digest"     => SHA,
            "repository" => "mssola/busybox",
            "url"        => "http://registry.test.lan/v2/mssola/busybox/manifests/#{SHA}"
          }
        }.freeze

      DELETE =
        {
          "id"        => "6d673710-06b5-48b5-a7d9-94cbaacf776b",
          "timestamp" => "2016-04-13T15:03:39.595901492+02:00",
          "action"    => "delete",
          "target"    => {
            "digest"     => SHA,
            "repository" => "registry"
          },
          "request"   => {
            "id"        => "fae66612-ef48-4157-8994-bd146fbdd951",
            "addr"      => "127.0.0.1:55452",
            "host"      => "registry.mssola.cat:5000",
            "method"    => "DELETE",
            "useragent" => "Ruby"
          },
          "actor"     => {
            "name" => "portus"
          },
          "source"    => {
            "addr"       => "bucket:5000",
            "instanceID" => "741bc03b-6ebe-4ffc-b6b1-4b33d5fc2090"
          }
        }.freeze

      UA = "docker/1.9.1 go/go1.5.2 git-commit/a34a1d5 kernel/4.4.0-1-default os/linux arch/amd64"
      VERSION23 =
        {
          "id"        => "7dc1c55c-dfe2-4699-ab0b-8f32e89882ce",
          "timestamp" => "2016-02-05T11:16:14.917994087+01:00",
          "action"    => "push",
          "target"    => {
            "mediaType"  => "application/vnd.docker.distribution.manifest.v1+prettyjws",
            "size"       => 2739,
            "digest"     => SHA,
            "length"     => 2739,
            "repository" => "mssola/lala",
            "url"        => "https://registry.mssola.cat:5000/v2/mssola/lala/manifests/#{SHA}"
          },
          "request"   => {
            "id"        => "e30471d8-39c3-41c0-abc2-775ed43e81c9",
            "addr"      => "127.0.0.1:54032",
            "host"      => "registry.mssola.cat:5000",
            "method"    => "PUT",
            "useragent" => UA
          },
          "actor"     => {
            "name" => "mssola"
          },
          "source"    => {
            "addr"       => "g67:5000",
            "instanceID" => "18771ece-0887-40f8-ad53-ee46451b4d8b"
          }
        }.freeze
    end
  end
end
