# frozen_string_literal: true

module API
  module V1
    # Concern for declaration of ordering parameters.
    #
    # @example
    #   class ApiResource < Grape::API
    #     include OrderingParams
    #
    #     params do
    #       use :ordering
    #     end
    #   end
    module OrderingParams
      extend ActiveSupport::Concern

      included do
        helpers do
          params :ordering do
            optional :sort_attr, type: String, default: :id, desc: "Current page number"
            optional :sort_order, type: String, default: :asc, desc: "Number of items per page"
          end
        end
      end
    end
  end
end
