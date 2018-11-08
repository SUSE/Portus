# frozen_string_literal: true

require "grape-swagger"

require "api/entities"
require "api/helpers"
require "api/v1/pagination_params"
require "api/v1/ordering_params"
require "api/v1/application_tokens"
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

    ##
    # Catching exceptions.

    # Rails, Pundit & Grape exceptions.

    rescue_from ActiveRecord::RecordNotFound do
      not_found!
    end

    rescue_from Grape::Exceptions::MethodNotAllowed do |e|
      method_not_allowed!(e.message)
    end

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      bad_request!(e.errors)
    end

    rescue_from Grape::Exceptions::InvalidMessageBody do |e|
      msg = e.message.split("\n").last.strip.capitalize
      bad_request!(msg)
    end

    rescue_from Pundit::NotAuthorizedError do |_|
      forbidden!("Authorization fails")
    end

    # Own exceptions.

    rescue_from ::Portus::Errors::NotFoundError do |e|
      not_found!(e.message)
    end

    rescue_from ::Portus::Errors::UnprocessableEntity do |e|
      unprocessable_entity!(e.message)
    end

    # Global exception handler, used for error notifications
    rescue_from :all do |e|
      internal_server_error!(e)
    end

    # We are using the same formatter for any error that might be raised. The
    # _ignored parameter include (in order): backtrace, options, env and
    # original_exception.
    error_formatter :json, ->(message, *_ignored) { { message: message }.to_json }

    helpers Pundit
    helpers ::API::Helpers

    mount ::API::V1::ApplicationTokens
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
      not_found!
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
