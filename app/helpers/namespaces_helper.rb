# frozen_string_literal: true

require "api/helpers/namespaces"

module NamespacesHelper
  # TODO: remove on future refactor
  include API::Helpers::Namespaces

  def can_create_namespace?
    current_user.admin? || APP_CONFIG.enabled?("user_permission.create_namespace")
  end
end
