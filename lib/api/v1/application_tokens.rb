# frozen_string_literal: true

require "api/helpers/application_tokens"

module API
  module V1
    # ApplicationTokens implements all the endpoints regarding application tokens.
    class ApplicationTokens < Grape::API
      version "v1", using: :path

      helpers ::API::Helpers::ApplicationTokens

      resource :users do
        namespace do
          before do
            authorization!(force_admin: false)
          end

          route_param :id, type: Integer do
            resource :application_tokens do
              # List application tokens beloged to user with given :id.
              desc "Returns list of user's tokens",
                   params:   API::Entities::Users.documentation.slice(:id),
                   is_array: true,
                   entity:   API::Entities::ApplicationTokens,
                   failure:  [
                     [401, "Authentication fails"],
                     [403, "Authorization fails"],
                     [404, "Not found"]
                   ]

              get do
                user = User.find params[:id]
                present user.application_tokens,
                        with: API::Entities::ApplicationTokens
              end

              # Create application token for user with given :id.
              desc "Create user's token",
                   params:   API::Entities::Users.documentation.slice(:id),
                   success:  { code: 200 },
                   entity:   API::Entities::ApplicationTokens,
                   failure:  [
                     [400, "Bad request", API::Entities::ApiErrors],
                     [401, "Authentication fails"],
                     [403, "Authorization fails"],
                     [422, "Unprocessable Entity", API::Entities::FullApiErrors]
                   ],
                   consumes: ["application/x-www-form-urlencoded", "application/json"]

              params do
                requires :application, documentation: { desc: "Application name" }
              end

              post do
                create_application_token!(@user, params[:id], declared(params.slice(:application)))
              end
            end
          end

          resource :application_tokens do
            desc "Delete application token",
                 failure: [
                   [401, "Authentication fails"],
                   [403, "Authorization fails"],
                   [404, "Not found"]
                 ]

            params do
              requires :id, documentation: { desc: "Token id" }
            end

            delete ":id" do
              token = ApplicationToken.find(params[:id])

              authorize token, :destroy?

              token.create_activity! :destroy, @user
              token.destroy
              status 204
            end
          end
        end
      end
    end
  end
end
