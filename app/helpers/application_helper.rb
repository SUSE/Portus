# frozen_string_literal: true

module ApplicationHelper
  include ActivitiesHelper

  ACTION_ALIASES = {
    "update" => "edit",
    "create" => "new"
  }.freeze

  def app_host
    request.env["HTTP_HOST"]
  end

  def app_relative_url_root
    ENV["RAILS_RELATIVE_URL_ROOT"] || ""
  end

  def app_path
    path = File.join(app_host, app_relative_url_root)
    path.chomp("/")
  end

  def js_route
    action_name = ACTION_ALIASES[controller.action_name] || controller.action_name

    "#{js_controller}/#{action_name}"
  end

  def js_controller
    controller.class.name.underscore.gsub("_controller", "")
  end

  # Render the user profile picture depending on the gravatar configuration.
  def user_image_tag(user)
    if user&.avatar_url.present?
      content_tag :img, nil, src: user.avatar_url
    else
      content_tag :i, nil, class: "fa fa-user user-picture"
    end
  end

  # Render the image tag that is suitable for activities.
  def activity_time_tag(ct)
    time_tag ct, time_ago_in_words(ct), title: ct
  end

  # Returns true of signup is enabled.
  def signup_enabled?
    APP_CONFIG.disabled?("ldap") && APP_CONFIG.enabled?("signup")
  end

  # Returns true if the login form should show the "first user admin" alert.
  def show_first_user_alert?
    User.not_portus.none? && APP_CONFIG.enabled?("first_user_admin") && APP_CONFIG.enabled?("ldap")
  end

  # Returns pagination limit config
  def pagination_per_page
    APP_CONFIG["pagination"]["per_page"]
  end

  # Returns pagination before after config
  def pagination_before_after
    APP_CONFIG["pagination"]["before_after"]
  end

  # Returns `active` string if current path includes the passed parameter
  # or if paremeter is `true`.
  def active_page?(path_or_bool)
    case path_or_bool
    when String
      "active" if request.fullpath.include?(path_or_bool)
    when TrueClass
      "active"
    end
  end

  # Render markdown to safe HTML.
  # Images, unsafe link protocols and styles are not allowed to render.
  # HTML-Tags will be filtered.
  def markdown(text)
    extensions = {
      superscript:                  true,
      disable_indented_code_blocks: true,
      fenced_code_blocks:           true
    }
    render_options = {
      filter_html:         true,
      no_images:           true,
      no_styles:           true,
      safe_links_only:     true,
      space_after_headers: true
    }

    renderer = Redcarpet::Render::HTML.new(render_options)
    m = Redcarpet::Markdown.new(renderer, extensions)

    sanitize(m.render(text))
  end
end
