# frozen_string_literal: true

module API
  module Helpers
    module Ordering
      def order(relation)
        relation.order(params[:sort_attr] => params[:sort_order])
      end
    end
  end
end
