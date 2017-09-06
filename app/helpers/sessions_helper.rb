#
# Renders the social login buttons if one of the `oauth` configuration has been enabled.
#
module SessionsHelper
  def social_login
    return unless APP_CONFIG["oauth"]
    enabled_providers = APP_CONFIG["oauth"].find_all { |_k, v| v["enabled"] }
    render partial: "devise/sessions/social_login" unless enabled_providers.empty?
  end
end
