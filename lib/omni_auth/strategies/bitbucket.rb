require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class Bitbucket < OmniAuth::Strategies::OAuth2
      option :name, "bitbucket"
      option :client_options,
        site:          "https://bitbucket.org",
        authorize_url: "https://bitbucket.org/site/oauth2/authorize",
        token_url:     "https://bitbucket.org/site/oauth2/access_token"

      uid { raw_info["uuid"].to_s }

      info do
        {
          name:     raw_info["display_name"],
          nickname: raw_info["username"],
          email:    primary_email
        }
      end

      extra do
        { raw_info: raw_info }
      end

      def raw_info
        @raw_info ||= access_token.get("/api/2.0/user").parsed
      end

      def callback_url
        full_host + script_name + callback_path
      end

      def primary_email
        primary = emails.find { |i| i["is_primary"] && i["is_confirmed"] }
        primary && primary["email"] || nil
      end

      def emails
        email_response = access_token.get("/api/2.0/user/emails").parsed
        @emails ||= email_response && email_response["values"] || nil
      end

      def build_access_token_with_team_check
        access_token = build_access_token_without_team_check
        unless options.team.blank?
          teams = access_token.get("/api/2.0/teams?role=member").parsed["values"]
          teams.select! { |el| el["username"] == options.team }
          raise CallbackError.new(:invalid_team, "Invalid team") if teams.blank?
        end
        access_token
      end
      alias_method_chain :build_access_token, :team_check
    end
  end
end
