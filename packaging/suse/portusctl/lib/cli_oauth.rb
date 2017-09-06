module CliOAuth
  def self.included(thor)
    thor.class_eval do
      option "oauth-google-oauth2-enable",
        desc:    "OAuth: Google OAuth2 enable",
        type:    :boolean,
        default: false
      option "oauth-google-oauth2-id", desc: "OAuth: Google OAuth2 id"
      option "oauth-google-oauth2-secret", desc: "OAuth: Google OAuth2 secret"
      option "oauth-google-oauth2-domain", desc: "OAuth: Google OAuth2 email's domain restriction"
      option "oauth-google-oauth2-options-hd",
        desc: "OAuth: Google OAuth2 group (GSute) restriction"
      option "oauth-open-id-enable", desc: "OAuth: Open ID enable", type: :boolean, default: false
      option "oauth-open-id-identifier", desc: "OAuth: Open ID identifier"
      option "oauth-open-id-domain", desc: "OAuth: Open ID email's domain restriction"
      option "oauth-github-enable", desc: "OAuth: Github enable", type: :boolean, default: false
      option "oauth-github-key", desc: "OAuth: Github key"
      option "oauth-github-secret", desc: "OAuth: Github secret"
      option "oauth-github-organization", desc: "OAuth: Github organization restriction"
      option "oauth-github-team", desc: "OAuth: Github team restriction"
      option "oauth-github-domain", desc: "OAuth: Github email's domain restriction"
      option "oauth-gitlab-enable", desc: "OAuth: Gitlab enable", type: :boolean, default: false
      option "oauth-gitlab-id", desc: "OAuth: Gitlab id"
      option "oauth-gitlab-secret", desc: "OAuth: Gitlab secret"
      option "oauth-gitlab-group", desc: "OAuth: Gitlab group restriction"
      option "oauth-gitlab-domain", desc: "OAuth: Gitlab email's domain restriction"
      option "oauth-bitbucket-enable",
        desc: "OAuth: Bitbucket enable", type: :boolean, default: false
      option "oauth-bitbucket-key", desc: "OAuth: Bitbucket key"
      option "oauth-bitbucket-secret", desc: "OAuth: Bitbucket secret"
      option "oauth-bitbucket-domain", desc: "OAuth: Bitbucket domain restriction"
      option "oauth-bitbucket-options-team", desc: "OAuth: Bitbucket team restriction"
    end
  end
end
