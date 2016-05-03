class TagsController < ApplicationController
  include DeleteEnabled

  # Removes all tags the match the digest of the tag with the given ID.
  # Moreover, it will also remove the image if it's left empty after removing
  # the tags.
  def destroy
    tag = Tag.find(params[:id])

    # And now remove the tag by the digest. If the repository containing said
    # tags becomes empty after that, remove it too.
    repo = tag.repository
    if tag.delete_by_digest!(current_user)
      if repo.tags.empty?
        repo.delete_and_update!(current_user)
        redirect_to namespace_path(repo.namespace), notice: "Image removed with all its tags"
      else
        redirect_to repository_path(tag.repository), notice: "Tag removed successfully"
      end
    else
      redirect_to repository_path(tag.repository), alert: "Tag could not be removed"
    end
  end
end
