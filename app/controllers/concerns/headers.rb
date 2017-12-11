# frozen_string_literal: true

# Concern which has methods dealing with headers that might be interesting for
# controllers deriving directly from ActionController::Base.
module Headers
  extend ActiveSupport::Concern

  included do
    after_action :default_headers
  end

  # Adds some default headers.
  def default_headers
    headers["X-UA-Compatible"] = "IE=edge"
  end
end
