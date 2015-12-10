# Rendering push activities can be tricky, since tags can come on go, and with
# them, dangling repositories that used to contain them. Because of this, this
# helper renders the proper HTML for push activities, while being safe at it.
module RepositoriesHelper
  # Renders a create activity, that is, an automated repository has just been created
  def render_create_activity(activity)
    owner = content_tag(:strong, "#{fetch_owner(activity)} created ")

    namespace = render_namespace(activity)
    namespace += " / " unless namespace.empty?

    source_url = content_tag(:code, activity.parameters[:source_url])

    owner + namespace + render_repository(activity) + " with source URL set to " + source_url
  end

  # Renders a edit activity, that is, a repository has just been edited
  def render_edit_activity(activity)
    owner = content_tag(:strong, "#{fetch_owner(activity)} edited ")

    namespace = render_namespace(activity)
    namespace += " / " unless namespace.empty?

    old_source = activity.parameters[:old_source]
    new_source = activity.parameters[:new_source]

    message = ActiveSupport::SafeBuffer.new("")

    if old_source.blank?
      unless new_source.blank?
        message << " set source URL to "
        message << content_tag(:code, new_source)
      end
    else
      if new_source.blank?
        message = " making it a non-automated repository"
      else
        message << " changing source URL from "
        message << content_tag(:code, old_source)
        message << " to "
        message << content_tag(:code, new_source)
      end
    end

    owner + namespace + render_repository(activity) + message
  end

  # Renders a push activity, that is, a repository has been pushed.
  def render_push_activity(activity)
    owner = content_tag(:strong, "#{fetch_owner(activity)} pushed ")

    namespace = render_namespace(activity)
    namespace += " / " unless namespace.empty?

    owner + namespace + render_repository(activity)
  end

  # Returns true if the current user can trigger an automated
  # build for a given repository
  def can_trigger_build?(repository)
    return false unless APP_CONFIG.enabled?("navalia")
    return false if repository.source_url.blank?

    current_user.admin? || \
      repository.namespace.team.owners.exists?(current_user.id) || \
      repository.namespace.team.contributors.exists?(current_user.id)
  end

  protected

  # Fetches the owner of the activity in a safe way.
  def fetch_owner(activity)
    activity.owner.nil? ? "Someone" : activity.owner.username
  end

  # Renders the namespace part of the activity in a safe manner. If the
  # namespace still exists, it will be taken as the target for the created
  # link. Otherwise, it will try to fetch the name of the namespace and put it
  # inside of a <span> element. If this is not possible, then an empty string
  # will be returned.
  def render_namespace(activity)
    tr = activity.trackable

    if tr.nil?
      if activity.parameters[:namespace_name].nil?
        ""
      else
        namespace = Namespace.find_by(id: activity.parameters[:namespace_id])
        if namespace.nil?
          content_tag(:span, activity.parameters[:namespace_name])
        else
          link_to activity.parameters[:namespace_name], namespace
        end
      end
    else
      link_to tr.namespace.clean_name, tr.namespace
    end
  end

  # Renders the repository part of the activity in a safe manner.
  def render_repository(activity)
    repo, link, tag = get_repo_link_tag(activity)

    if link.nil?
      content_tag(:span, "#{repo}#{tag}")
    else
      link_to "#{repo}#{tag}", link
    end
  end

  # Helper for the render_repository method.
  def get_repo_link_tag(activity)
    tr = activity.trackable

    if tr.nil?
      if activity.parameters[:repo_name].nil?
        ["a repository", nil, ""]
      else
        repo = activity.parameters[:repo_name]
        ns   = Namespace.find_by(id: activity.parameters[:namespace_id])
        link = ns.nil? ? nil : namespace_path(ns.id)
        [repo, link, tag_part(activity)]
      end
    else
      [tr.name, tr, tag_part(activity)]
    end
  end

  # Renders the tag for the given activity. It will return an empty string if
  # the tag could not be found, otherwise it will return the tag with a ":"
  # prefixed to it.
  def tag_part(activity)
    if activity.recipient.nil?
      if activity.parameters[:tag_name].nil?
        ""
      else
        ":#{activity.parameters[:tag_name]}"
      end
    else
      ":#{activity.recipient.name}"
    end
  end
end
