# frozen_string_literal: true

module API
  module Helpers
    # Helpers for namespaces
    module Namespaces
      # Returns an aggregate of the accessible namespaces for the current user.
      def accessible_namespaces
        special = Namespace.special_for(current_user).order(created_at: :asc)
        normal  = policy_scope(Namespace).order(created_at: :asc)
        special + normal
      end
    end
  end
end
