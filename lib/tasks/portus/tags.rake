# frozen_string_literal: true

require_relative "../helpers"

# Returns the tags to be updated. It accepts the `force` argument in which it
# will force the update to all tags.
def tags_to_update(force)
  tags = if ::Helpers.truthy?(force)
           Tag.all
         else
           Tag.where("tags.digest='' OR tags.image_id=''")
         end

  if tags.empty?
    puts "There are no tags to be updated."
    exit 0
  else
    puts "Updating a total of #{tags.size} tags..."
  end

  tags
end

# Warn the user about the duration of this task and possibly ask whether to exit
# early.
def warn_user!
  puts <<~HERE
    This rake task may take a while depending on how many images have been stored
    in your private registry. If you are running this in production it's
    recommended that the registry is running in "readonly" mode, so there are no
    race conditions with concurrent accesses.

  HERE

  return if ENV["PORTUS_FORCE_DIGEST_UPDATE"]

  msg = "Are you sure that you want to proceed with this ? (y/n) "
  exit 0 unless ::Helpers.are_you_sure?(msg)
end

namespace :portus do
  desc "Update the manifest digest of tags"
  task :update_tags, [:update] => [:environment] do |_, args|
    warn_user!

    tags = tags_to_update(args[:update])

    # And for each tag fetch its digest and update the DB.
    client = Registry.get.client
    tags.each_with_index do |t, index|
      repo_name = t.repository.name
      puts "[#{index + 1}/#{tags.size}] Updating #{repo_name}/#{t.name}"

      begin
        id, digest, = client.manifest(t.repository.full_name, t.name)
        t.update(digest: digest, image_id: id)
      rescue ::Portus::RequestError, ::Portus::Errors::NotFoundError,
             ::Portus::RegistryClient::ManifestError => e
        puts "Could not get the manifest for #{repo_name}: #{e}"
      end
    end
    puts
  end
end
