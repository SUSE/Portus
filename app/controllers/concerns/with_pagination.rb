# frozen_string_literal: true

# Concern for handling of pagination parameters.
module WithPagination
  extend ActiveSupport::Concern

  include ::API::Helpers::Pagination

  included do
    before_action :default_pagination_params
  end

  # Adds some default pagination parameters.
  def default_pagination_params
    params[:page] ||= 1
    params[:per_page] = APP_CONFIG["pagination"]["per_page"]
  end

  def header(header, value)
    response.headers[header] = value
  end
end
