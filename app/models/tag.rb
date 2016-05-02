# == Schema Information
#
# Table name: tags
#
#  id            :integer          not null, primary key
#  name          :string(255)      default("latest"), not null
#  repository_id :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :integer
#  digest        :string(255)
#  image_id      :string(255)      default("")
#
# Indexes
#
#  index_tags_on_name_and_repository_id  (name,repository_id) UNIQUE
#  index_tags_on_repository_id           (repository_id)
#  index_tags_on_user_id                 (user_id)
#

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
