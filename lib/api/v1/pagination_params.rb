# frozen_string_literal: true

module API
  module V1
    # Concern for declaration of pagination parameters.
    #
    #
    # @example
    #   class ApiResource < Grape::API
    #     include PaginationParams
    #
    #     params do
    #       use :pagination
    #     end
    #   end
    module PaginationParams
      extend ActiveSupport::Concern

      included do
        helpers do
          params :pagination do
            optional :all, type: Grape::API::Boolean, default: false, desc: "Ignores pagination"
            optional :page, type: Integer, default: 1, desc: "Current page number"
            optional :per_page, type: Integer, default: 15, desc: "Number of items per page"
          end
        end
      end
    end
  end
end
