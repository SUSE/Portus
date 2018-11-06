# frozen_string_literal: true

module API
  module Helpers
    # Ordering implements a helper responsible for the resource entries ordering that
    # can be customized through request parameters like `sort_attr` and `sort_order`.
    module Ordering
      def order(relation)
        relation.order(params[:sort_attr] => params[:sort_order])
      end
    end
  end
end
