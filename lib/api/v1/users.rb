module API
  module V1
    class Users < Grape::API
      version "v1", using: :path

      resource :users do
        before do
          authorization!(force_admin: true)
        end

        route_param :id, type: Integer do
          resource :application_tokens do
            # List application tokens beloged to user with given :id.
            desc "Returns list of user's tokens.",
              params:   API::Entities::Users.documentation.slice(:id),
              is_array: true,
              entity:   API::Entities::ApplicationTokens,
              failure:  [
                [401, "Authentication fails."],
                [403, "Authorization fails."],
                [404, "Not found."]
              ]

            get do
              user = User.find params[:id]
              present user.application_tokens,
                with: API::Entities::ApplicationTokens
            end

            # Create application token for user with given :id.
            desc "Create user's token.",
              params:   API::Entities::Users.documentation.slice(:id),
              success:  { code: 200 },
              entity:   API::Entities::ApplicationTokens,
              failure:  [
                [400, "Bad request.", API::Entities::ApiErrors],
                [401, "Authentication fails."],
                [403, "Authorization fails."]
              ],
              consumes: ["application/x-www-form-urlencoded", "application/json"]

            params do
              requires :application, documentation: { desc: "Application name" }
            end

            post do
              application_token, plain_token = ApplicationToken.create_token(
                current_user: @user,
                user_id:      params[:id],
                params:       declared(params.slice(:application))
              )

              if application_token.errors.empty?
                status 200
                { plain_token: plain_token }
              else
                status 400
                { errors: application_token.errors }
              end
            end
          end
        end

        resource :application_tokens do
          desc "Delete application token.",
            failure: [
              [401, "Authentication fails."],
              [403, "Authorization fails."],
              [404, "Not found."]
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

        desc "Create new user.",
          failure:  [
            [400, "Bad request.", API::Entities::ApiErrors],
            [401, "Authentication fails."],
            [403, "Authorization fails."]
          ],
          consumes: ["application/x-www-form-urlencoded", "application/json"]

        params do
          requires :user, type: Hash do
            requires :all,
              only:  [:username, :email],
              using: API::Entities::Users.documentation.slice(:username, :email)
            requires :password, type: String
            optional :all,
              only:  [:display_name],
              using: API::Entities::Users.documentation.slice(:display_name)
          end
        end

        post do
          user = User.create declared(params)[:user]
          if user.valid?
            user
          else
            status 400
            { errors: user.errors }
          end
        end

        # Update user with given :id.
        desc "Update user.",
          params:   API::Entities::Users.documentation.slice(:id),
          failure:  [
            [400, "Bad request.", API::Entities::ApiErrors],
            [401, "Authentication fails."],
            [403, "Authorization fails."],
            [404, "Not found."]
          ],
          consumes: ["application/x-www-form-urlencoded", "application/json"]

        params do
          requires :user, type: Hash do
            optional :all,
              only:  [:username, :email],
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
            user
          else
            status 400
            { errors: user.errors }
          end
        end

        # Delete user with given :id.
        desc "Delete user.",
          params:  API::Entities::Users.documentation.slice(:id),
          failure: [
            [401, "Authentication fails."],
            [403, "Authorization fails."],
            [404, "Not found."]
          ]

        delete ":id" do
          user = User.find(params[:id])
          user.update_activities! @user
          user.destroy
          status 204
        end

        desc "Returns list of users.",
          tags:     ["users"],
          detail:   "This will expose all users.",
          is_array: true,
          entity:   API::Entities::Users,
          failure:  [
            [401, "Authentication fails."],
            [403, "Authorization fails."]
          ]

        get do
          users = User.all
          present users, with: API::Entities::Users
        end

        route_param :id, type: String, requirements: { id: /.*/ } do

          # Find user by id or email and return.
          desc "Show user by id or email.",
            entity:  API::Entities::Users,
            failure: [
              [401, "Authentication fails."],
              [403, "Authorization fails."],
              [404, "Not found."]
            ]

          params do
            requires :id, type: String, documentation: { desc: "User id or email." }
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
    end
  end
end
