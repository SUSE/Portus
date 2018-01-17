# frozen_string_literal: true

# Deletable redirects the user back if delete support is not enabled. A
# `before_action` will be created for the :destroy method.
module Deletable
  extend ActiveSupport::Concern

  included do
    # rubocop:disable Rails/LexicallyScopedActionFilter
    before_action :delete_enabled?, only: [:destroy]
    # rubocop:enable Rails/LexicallyScopedActionFilter
  end

  # Returns true if users can delete images/tags.
  def delete_enabled?
    redirect_to :back, status: :forbidden unless APP_CONFIG.enabled?("delete")
  end
end
