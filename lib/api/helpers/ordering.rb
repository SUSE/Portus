# frozen_string_literal: true

module API
  module Helpers
    # Ordering implements a helper responsible for the resource entries ordering that
    # can be customized through request parameters like `sort_attr` and `sort_order`.
    module Ordering
      def order(relation)
        relation.order(sanitized_attr(relation) => sanitized_order)
      end

      private

      def sanitized_order
        params[:sort_order] == "asc" ? :asc : :desc
      end

      def sanitized_attr(relation)
        attribute = params[:sort_attr]
        relation.model.respond_to?(attribute) ? attribute : :id
      end
    end
  end
end
