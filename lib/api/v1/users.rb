# frozen_string_literal: true

require "api/helpers/application_tokens"

module API
  module V1
    # Users implements all the endpoints regarding users and application tokens.
    class Users < Grape::API
      version "v1", using: :path

      helpers ::API::Helpers::ApplicationTokens

      resource :users do
        namespace do
          before do
            authorization!(force_admin: true)
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
              token.create_activity! :destroy, @user
              token.destroy
              status 204
            end
          end

          desc "Create new user",
               failure:  [
                 [400, "Bad request", API::Entities::ApiErrors],
                 [401, "Authentication fails"],
                 [403, "Authorization fails"],
                 [422, "Unprocessable Entity", API::Entities::FullApiErrors]
               ],
               entity:   API::Entities::Users,
               consumes: ["application/x-www-form-urlencoded", "application/json"]

          params do
            requires :user, type: Hash do
              requires :all,
                       only:  %i[username email],
                       using: API::Entities::Users.documentation.slice(:username, :email)
              requires :password, type: String, documentation: { desc: "Password" }
              optional :all,
                       only:  [:display_name],
                       using: API::Entities::Users.documentation.slice(:display_name)
            end
          end

          post do
            user = User.create declared(params)[:user]
            if user.valid?
              present user, with: API::Entities::Users
            else
              unprocessable_entity!(user.errors)
            end
          end

          # Update user with given :id.
          desc "Update user",
               params:   API::Entities::Users.documentation.slice(:id),
               failure:  [
                 [400, "Bad request", API::Entities::ApiErrors],
                 [401, "Authentication fails"],
                 [403, "Authorization fails"],
                 [404, "Not found"],
                 [422, "Unprocessable Entity", API::Entities::FullApiErrors]
               ],
               entity:   API::Entities::Users,
               consumes: ["application/x-www-form-urlencoded", "application/json"]

          params do
            requires :user, type: Hash do
              optional :all,
                       only:  %i[username email],
                       using: API::Entities::Users.documentation.slice(:username, :email)
              optional :password, type: String, desc: "Password"
              optional :all,
                       only:  [:display_name],
                       using: API::Entities::Users.documentation.slice(:display_name)
            end
          end

          put ":id" do
            attrs = declared(params, include_missing: false)[:user]
            user = User.update(params[:id], attrs)
            if user.valid?
              present user, with: API::Entities::Users
            else
              unprocessable_entity!(user.errors)
            end
          end

          # Delete user with given :id.
          desc "Delete user",
               params:  API::Entities::Users.documentation.slice(:id),
               failure: [
                 [401, "Authentication fails"],
                 [403, "Authorization fails"],
                 [404, "Not found"]
               ]

          delete ":id" do
            user = User.find(params[:id])
            user.update_activities! @user
            user.destroy
            status 204
          end

          desc "Returns list of users",
               tags:     ["users"],
               detail:   "This will expose all users",
               is_array: true,
               entity:   API::Entities::Users,
               failure:  [
                 [401, "Authentication fails"],
                 [403, "Authorization fails"]
               ]

          get do
            users = User.all
            present users, with: API::Entities::Users
          end

          route_param :id, type: String, requirements: { id: /.*/ } do
            # Find user by id or email and return.
            desc "Show user by id or email",
                 entity:  API::Entities::Users,
                 failure: [
                   [401, "Authentication fails"],
                   [403, "Authorization fails"],
                   [404, "Not found"]
                 ]

            params do
              requires :id, type: String, documentation: { desc: "User ID or email" }
            end

            get do
              user = begin
                       User.find params[:id]
                     rescue ActiveRecord::RecordNotFound
                       nil
                     end
              user ||= User.find_by(email: params[:id])
              raise ActiveRecord::RecordNotFound unless user
              present user, with: API::Entities::Users
            end
          end
        end

        namespace do
          desc "Create the first admin user",
               failure:  [
                 [400, "Bad request", API::Entities::ApiErrors],
                 [401, "Authentication fails"],
                 [403, "Authorization fails"],
                 [405, "Method Not Allowed", API::Entities::ApiErrors],
                 [422, "Unprocessable Entity", API::Entities::FullApiErrors]
               ],
               detail:   "Use this method to create the first admin user. The" \
                         " response will include an application token so you can use this user" \
                         " right away. This method should be used when bootstrapping a Portus" \
                         " instance by using the REST API. Last but not least, it will" \
                         " respond with a 405 if the `first_user_admin` configuration value" \
                         " has been disabled",
               tags:     ["users"],
               entity:   API::Entities::ApplicationTokens,
               consumes: ["application/x-www-form-urlencoded", "application/json"]

          params do
            requires :user, type: Hash do
              requires :all,
                       only:  %i[username email],
                       using: API::Entities::Users.documentation.slice(:username, :email)
              requires :password, type: String, documentation: { desc: "Password" }
              optional :all,
                       only:  [:display_name],
                       using: API::Entities::Users.documentation.slice(:display_name)
            end
          end

          post "/bootstrap" do
            if !APP_CONFIG.enabled?("first_user_admin")
              method_not_allowed!("this instance has disabled this endpoint")
            elsif User.not_portus.any?
              bad_request!("you can only use this when there are no users on the system")
            else
              ps = declared(params)[:user]
              ps[:admin] = true

              user = User.create ps
              create_application_token!(user, user.id, application: "bootstrap")
            end
          end
        end
      end
    end
  end
end
