# frozen_string_literal: true

# Concern for handling of ordering parameters.
module WithOrdering
  extend ActiveSupport::Concern

  include ::API::Helpers::Ordering

  included do
    before_action :default_ordering_params
  end

  # Adds some default ordering parameters.
  def default_ordering_params
    params[:sort_attr] ||= :id
    params[:sort_order] ||= :asc
  end
end
