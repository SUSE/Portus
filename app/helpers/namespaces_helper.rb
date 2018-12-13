# frozen_string_literal: true

require "api/helpers/namespaces"

module NamespacesHelper
  # TODO: remove on future refactor
  include API::Helpers::Namespaces

  def can_create_namespace?
    current_user.admin? || APP_CONFIG.enabled?("user_permission.create_namespace")
  end

  # Render the name for the namespace from the given activity. An article can be
  # prepended to the activity if `article` is set to true (e.g. "deleted the
  # namespace" vs "deleted namespace").
  #
  # NOTE: to be removed when working on #1936,
  def render_namespace_name(activity, article = false)
    name = activity.parameters[:namespace_name]

    if name
      articled("the ", content_tag(:strong, name), article)
    elsif activity.trackable && activity.trackable_type == "Namespace"
      articled("the ", link_to(activity.trackable.name, activity.trackable), article)
    else
      articled(name, "a", article)
    end
  end

  # Render the team for the namespace from the given activity.
  #
  # NOTE: to be removed when working on #1936,
  def render_namespace_team(activity)
    name = activity.parameters[:team]

    if activity.trackable_type == "Namespace" && activity.trackable&.team
      content_tag(:span, "the ") + link_to(activity.trackable.team.name, activity.trackable.team)
    elsif name
      content_tag(:span, "the ") + content_tag(:strong, name)
    else
      content_tag(:span, "a")
    end
  end

  protected

  # NOTE: to be removed when working on #1936,
  def articled(pre, post, article)
    article ? content_tag(:span, pre) + post : post
  end
end
