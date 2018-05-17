# frozen_string_literal: true

# CheckLDAP redirects the user to the new_user_session_path if LDAP support is
# enabled. A `before_action` will be created for the :new and the :create
# methods.
module CheckLDAP
  extend ActiveSupport::Concern

  included do
    # rubocop:disable Rails/LexicallyScopedActionFilter
    before_action :check_ldap, only: %i[new create]
    # rubocop:enable Rails/LexicallyScopedActionFilter
  end

  # Redirect to the login page if LDAP is enabled.
  def check_ldap
    redirect_to new_user_session_path if APP_CONFIG.enabled?("ldap")
  end
end
