# frozen_string_literal: true

module WebhooksHelper
  def can_create_webhook?(namespace)
    WebhookPolicy.new(current_user, namespace.webhooks.build).create?
  end
end
