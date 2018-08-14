# frozen_string_literal: true

module API
  module Helpers
    # Helpers of namespaces
    module Namespaces
      def can_manage_namespace?(namespace, user)
        NamespacePolicy.new(user, namespace).update?
      end

      def can_destroy_namespace?(namespace, user)
        NamespacePolicy.new(user, namespace).destroy? && !User.exists?(namespace: namespace)
      end

      def can_change_visibility?(namespace, user)
        NamespacePolicy.new(user, namespace).change_visibility?
      end

      def can_pull?(namespace, user)
        NamespacePolicy.new(user, namespace).pull?
      end

      def can_push?(namespace, user)
        NamespacePolicy.new(user, namespace).push?
      end

      def role(namespace, user)
        policy = NamespacePolicy.new(user, namespace)

        if policy.owner?
          :owner
        elsif policy.contributor?
          :contributor
        elsif policy.viewer?
          :viewer
        elsif user.admin?
          :admin
        end
      end
    end
  end
end
