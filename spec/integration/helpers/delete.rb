# frozen_string_literal: true

# It accepts exactly two arguments: the repository name (full name) and the tag
# name. With these two things, it will simply issue a delete request to the
# Registry.

require "portus/registry_client"

REPOSITORY = ARGV.first.dup
TAG        = ARGV.last.dup

RegistryEvent.all.destroy_all

client = Registry.get.client
manifest = client.manifest(REPOSITORY, TAG)
client.delete(REPOSITORY, manifest.digest, "manifests")
