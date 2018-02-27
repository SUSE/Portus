# frozen_string_literal: true

require "grape-swagger"

require "api/entities"
require "api/helpers"
require "api/v1/health"
require "api/v1/namespaces"
require "api/v1/registries"
require "api/v1/repositories"
require "api/v1/tags"
require "api/v1/teams"
require "api/v1/users"
require "api/v1/vulnerabilities"
require "api/version"

module API
  class RootAPI < Grape::API
    format :json
    prefix :api

    before do
      header["Access-Control-Allow-Origin"] = "*"
      header["Access-Control-Request-Method"] = "*"
      header["Access-Control-Allow-Headers"] = "Content-Type, api_key, Authorization, portus-auth"
    end

    rescue_from ActiveRecord::RecordNotFound do
      error_response message: "Not found", status: 404
    end

    rescue_from Grape::Exceptions::MethodNotAllowed do |e|
      error_response message: { errors: e.message }, status: 405
    end

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      error_response message: { errors: e.errors }, status: 400
    end

    rescue_from Pundit::NotAuthorizedError do |_|
      error_response message: { errors: "Authorization fails" }, status: 403
    end

    # global exception handler, used for error notifications
    rescue_from :all do |e|
      error_response message: "Internal server error: #{e}", status: 500
    end

    helpers Pundit
    helpers ::API::Helpers

    mount ::API::V1::Health
    mount ::API::V1::Namespaces
    mount ::API::V1::Registries
    mount ::API::V1::Repositories
    mount ::API::V1::Tags
    mount ::API::V1::Teams
    mount ::API::V1::Users
    mount ::API::V1::Vulnerabilities
    mount ::API::Version

    route :any, "*path" do
      error!("Not found", 404)
    end

    add_swagger_documentation \
      mount_path:           "/openapi-spec",
      security_definitions: {
        api_key: {
          type: "apiKey",
          name: "Portus-Auth",
          in:   "header"
        }
      },
      security:             [api_key: []],
      info:                 {
        title:         "Portus API",
        description:   "Portus CRUD API",
        contact_name:  "Portus authors",
        contact_email: "portus-dev@googlegroups.com"
      }
  end
end
