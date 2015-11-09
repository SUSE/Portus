# A tag as defined by Docker. It belongs to a repository and an author. The
# name follows the format as defined in registry/api/v2/names.go from Docker's
# Distribution project. The default name for a tag is "latest".
class Tag < ActiveRecord::Base
  belongs_to :repository
  belongs_to :author, class_name: "User", foreign_key: "user_id"

  # We don't validate the tag, because we will fetch that from the registry,
  # and that's guaranteed to have a good format.
  validates :name, uniqueness: { scope: "repository_id" }

  # Delete this tag and update its activity.
  def delete_and_update!
    logger.tagged("catalog") { logger.info "Removed the tag '#{name}'." }
    PublicActivity::Activity.where(recipient: self).update_all(
      parameters: {
        namespace_id:   repository.namespace.id,
        namespace_name: repository.namespace.clean_name,
        repo_name:      repository.name,
        tag_name:       name
      }
    )
    destroy
  end
end
