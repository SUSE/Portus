require "grape-swagger"

module API
  module Entities
    class Users < Grape::Entity
      expose :id, documentation: { type: Integer, desc: "User id" }
      expose :username, documentation: { type: String, desc: "User name" }
      expose :email, documentation: { type: String, desc: "E-mail" }
      expose :current_sign_in_at, documentation: { type: DateTime }
      expose :last_sign_in_at, documentation: { type: DateTime }
      expose :created_at, :updated_at, documentation: { type: DateTime }
      expose :admin, :enabled, documentation: { type: "boolean" }
      expose :locked_at, documentation: { type: DateTime }
      expose :namespace_id, documentation: { type: Integer }
      expose :display_name, documentation: { type: String, desc: "Display name" }
    end

    class ApplicationTokens < Grape::Entity
      expose :id, unless: { type: :create }, documentation: { type: Integer }
      expose :application, unless: { type: :create }
      expose :plain_token, if: { type: :create }
    end

    class ApiErrors < Grape::Entity
      expose :errors, documentation: {
        type: "API::Entities::Messages", is_array: true
      }
    end

    class Messages < Grape::Entity
      expose :message
    end
  end

  # Load user api for rake task.
  require "api/v1/users"

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

    # global exception handler, used for error notifications
    rescue_from :all do |e|
      error_response message: "Internal server error: #{e}", status: 500
    end

    helpers do
      require "#{Rails.root}/app/controllers/concerns/auth_from_token"
      include AuthFromToken

      def authorization!
        return if request.request_method == "OPTIONS"
        @user = authenticate_user_from_authentication_token!
        error!("Authentication fails.", 401) unless @user
        error!("Authorization fails.", 403) unless @user.admin
      end
    end

    mount API::V1::Users

    schemes = ENV["PORTUS_CHECK_SSL_USAGE_ENABLED"] ? [:https] : [:http, :https]
    add_swagger_documentation \
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
      },
      schemes:              schemes
  end
end
