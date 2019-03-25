# frozen_string_literal: true

class Auth::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token

  # rubocop:disable Rails/LexicallyScopedActionFilter
  before_action :check_user, except: [:failure]
  # rubocop:enable Rails/LexicallyScopedActionFilter

  # GET /users/auth/:provider/callback. Providers redirect to the endpoint.
  # Callback for Google OAuth2.
  def google_oauth2
    kind = action_name.tr("_", " ").capitalize
    flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: kind
    sign_in_and_redirect @user, event: :authentication
  end

  # Callback for Open ID.
  alias open_id google_oauth2
  # Callback for Open ID Connect.
  alias openid_connect google_oauth2
  # Callback for GitHub. Need API permission to check team and organization membership.
  alias github google_oauth2
  # Callback for GitLab. Need API permission to check group membership.
  alias gitlab google_oauth2
  # Callback for Bitbucket.
  alias bitbucket google_oauth2

  protected

  def github_next(resp)
    # -> gitlab: x-next-page is in headers, and not empty
    resp.headers.key?("x-next-page") && \
      resp.headers["x-next-page"].present?
  end

  def gitlab_next(resp)
    # -> github: Link is in headers
    #            and if we are not on last page, we have a last link
    resp.headers.key?("Link") && \
      resp.headers["Link"].include?('rel="last"') && \
      !resp.headers.key?("x-next-page")
  end

  private

  # If user does not exist then ask for username and display_name.
  def check_user
    data = omniauth_data
    unless data
      redirect_to new_user_session_url
      return
    end
    return unless check_domain

    if (alert = check_membership)
      redirect_to new_user_session_url, alert: alert
      return
    end
    @user = User.find_by(email: data.info["email"])
    return if @user

    session["omniauth.auth"] = data.except(:extra)
    redirect_to users_oauth_url
  end

  # Checks if email's domain match to allowed domain.
  def check_domain
    domain = APP_CONFIG["oauth"][action_name]["domain"]
    # If domain is blank then all domains are allowed.
    return true if domain.blank?

    d = omniauth_data.info["email"].match(/(?<=@).*/).to_s
    if domain == d
      true
    else
      redirect_to new_user_session_url,
                  alert: "Email addresses on the domain #{d} aren't allowed."
      false
    end
  end

  # Checks membership of the user. If the user member of the group then return
  # nil otherwise return string message.
  def check_membership
    conf = APP_CONFIG["oauth"][action_name]

    case action_name
    when "github"
      github_member? conf
    when "gitlab"
      if conf["group"].present?
        # Get user's groups.
        server = conf.fetch("server", "").presence || "https://gitlab.com"
        is_member = member_of("#{server}/api/v4/groups", per_page: 100) do |g|
          g["name"] == conf["group"]
        end
        "The Gitlab account isn't in allowed group." unless is_member
      end
    end
  end

  # Checks if the user member of github organization and team.
  def github_member?(conf)
    server = conf.fetch("server", "").presence || "github.com"
    
    if conf["team"].present?
      # Get user's teams.
      is_member = member_of("https://api.#{server}/user/teams") do |t|
        t["name"] == conf["team"] &&
          t["organization"]["login"] == conf["organization"]
      end
      "The Github account isn't in allowed team." unless is_member
    elsif conf["organization"].present?
      # Get user's organizations.
      is_member = member_of("https://api.#{server}/user/orgs") do |t|
        t["login"] == conf["organization"]
      end
      "The Github account isn't in allowed organization." unless is_member
    end
  end

  # Get user's teams and check if one match to restriction.
  # This method uses pagination, and the caller can specify
  # the number of teams per page in the `per_page` parameter.
  def member_of(url, per_page: nil)
    # Get user's groups.
    token = omniauth_data.credentials["token"]
    teams = []
    np = 0
    loop do
      np += 1
      resp = Faraday.get url, { page: np, per_page: per_page,
                                access_token: token }.compact
      teams.concat JSON.parse resp.body
      # if no last/next page, we stop iteration
      break unless gitlab_next(resp) || github_next(resp)
    end

    # Check if the user is member of allowed group.
    !teams.find_all { |t| yield(t) }.empty?
  end

  # Returns the data for the omniauth auth for the current request.
  def omniauth_data
    request.env["omniauth.auth"]
  end
end
