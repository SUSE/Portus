# frozen_string_literal: true

class Auth::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token
  before_action :check_user, except: [:failure]

  # GET /users/auth/:provider/callback. Providers redirect to the endpoint.
  # Callback for Google OAuth2.
  def google_oauth2
    kind = action_name.tr("_", " ").capitalize
    flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: kind
    sign_in_and_redirect @user, event: :authentication
  end

  # Callback for Open ID.
  alias open_id google_oauth2
  # Callback for GitHub. Need API permission to check team and organization membership.
  alias github google_oauth2
  # Callback for GitLab. Need API permission to check group membership.
  alias gitlab google_oauth2
  # Callback for Bitbucket.
  alias bitbucket google_oauth2

  private

  # If user does not exist then ask for username and display_name.
  def check_user
    data = request.env["omniauth.auth"]
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
    d = request.env["omniauth.auth"].info["email"].match(/(?<=@).*/).to_s
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
        is_member = member_of("https://gitlab.com/api/v4/groups") do |g|
          g["name"] == conf["group"]
        end
        "The Gitlab account isn't in allowed group." unless is_member
      end
    end
  end

  # Checks if the user member of github organization and team.
  def github_member?(conf)
    if conf["team"].present?
      # Get user's teams.
      is_member = member_of("https://api.github.com/user/teams") do |t|
        t["name"] == conf["team"] &&
          t["organization"]["login"] == conf["organization"]
      end
      "The Github account isn't in allowed team." unless is_member
    elsif conf["organization"].present?
      # Get user's organizations.
      is_member = member_of("https://api.github.com/user/orgs") do |t|
        t["login"] == conf["organization"]
      end
      "The Github account isn't in allowed organization." unless is_member
    end
  end

  # Get user's teams and check if one match to restriction.
  def member_of(url)
    # Get user's groups.
    token = request.env["omniauth.auth"].credentials["token"]
    resp = Faraday.get url, access_token: token
    teams = JSON.parse resp.body

    # Check if the user is member of allowed group.
    !teams.find_all { |t| yield(t) }.empty?
  end
end
