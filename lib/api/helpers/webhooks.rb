# frozen_string_literal: true

module API
  module Helpers
    # Helpers of webhooks
    module Webhooks
      # Return true if user has permission to update a webhook
      # Returns false otherwise
      def can_manage_webhook?(webhook, user)
        WebhookPolicy.new(user, webhook).update?
      end

      def can_destroy_webhook?(webhook, user)
        WebhookPolicy.new(user, webhook).create?
      end
    end
  end
end
