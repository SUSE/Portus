module Portusctl
  module Options
    module Account
      def self.included(thor)
        thor.class_eval do
          # LDAP
          option "ldap-enable", desc: "LDAP: enable", type: :boolean, default: false
          option "ldap-hostname", desc: "LDAP: server hostname"
          option "ldap-port", desc: "LDAP: server port", default: "389"
          option "ldap-method",
                 desc:    "LDAP: encryption method (recommended: starttls)",
                 default: "plain"
          option "ldap-base", desc: "LDAP: base", default: "ou=users, dc=example, dc=com"
          option "ldap-filter", desc: "LDAP: filter users"
          option "ldap-uid", desc: "LDAP: uid", default: "uid"
          option "ldap-authentication-enable",
                 desc:    "LDAP: enable LDAP credentials for user lookup",
                 type:    :boolean,
                 default: false
          option "ldap-authentication-bind-dn", desc: "LDAP: bind DN for authentication"
          option "ldap-authentication-password", desc: "LDAP: password for authentication"
          option "ldap-guess-email-enable",
                 desc:    "LDAP: guess email address",
                 type:    :boolean,
                 default: false
          option "ldap-guess-email-attr",
                 desc: "LDAP: attribute to use when guessing email address"

          # SIGNUP
          option "signup-enable",
                 desc:    "Enable user signup",
                 type:    :boolean,
                 default: true

          # FIRST USER
          option "first-user-admin-enable",
                 desc:    "Make the first registered user an admin",
                 type:    :boolean,
                 default: true

          # Display name
          option "display-name-enable",
                 desc:    "Enable users to set a display name",
                 type:    :boolean,
                 default: false

          # GRAVATAR
          option "gravatar-enable",
                 desc:    "Enable Gravatar usage",
                 type:    :boolean,
                 default: true
        end
      end
    end
  end
end
