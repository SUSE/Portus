module API
  module V1
    class Teams < Grape::API
      version "v1", using: :path

      resource :teams do
        before do
          authorization!(force_admin: false)
        end

        desc "Returns list of teams.",
          tags:     ["teams"],
          detail:   "This will expose all teams.",
          is_array: true,
          entity:   API::Entities::Teams,
          failure:  [
            [401, "Authentication fails."],
            [403, "Authorization fails."]
          ]

        get do
          present policy_scope(Team), with: API::Entities::Teams
        end

        desc "Create a team",
          entity:  API::Entities::Teams,
          failure: [
            [401, "Authentication fails."],
            [403, "Authorization fails."]
          ]

        params do
          requires :name, type: String, documentation: { desc: "Team name." }
          optional :description, type: String, documentation: { desc: "Team description" }
        end

        post do
          authorize Team, :create?

          team = ::Teams::CreateService.new(current_user, permitted_params).execute

          if team.valid?
            present team,
                    with:         API::Entities::Teams,
                    current_user: current_user,
                    type:         current_type
          else
            error!({ "errors" => team.errors.full_messages }, 422, header)
          end
        end

        # Update team with given :id.
        desc "Update team",
             params:   API::Entities::Teams.documentation.slice(:id),
             failure:  [
               [400, "Bad request.", API::Entities::ApiErrors],
               [401, "Authentication fails."],
               [403, "Authorization fails."],
               [404, "Not found."]
             ],
             consumes: ["application/x-www-form-urlencoded", "application/json"]

        params do
          requires :team, type: Hash do
            optional :all,
                     only:  [:name],
                     using: API::Entities::Teams.documentation.slice(:name)
            optional :all,
                     only:  [:description],
                     using: API::Entities::Teams.documentation.slice(:description)
          end
        end

        put ":id" do
          attrs = permitted_params.merge(id: params[:id])
          ts = ::Teams::UpdateService.new(current_user, attrs)
          team = ts.build
          authorize team, :update?

          if ts.execute
            team.reload
          else
            status 400
            { errors: team.errors.messages }
          end
        end

        route_param :id, type: String, requirements: { id: /.*/ } do
          resource :namespaces do
            desc "Returns the list of namespaces for the given team",
              params:   API::Entities::Teams.documentation.slice(:id),
              is_array: true,
              entity:   API::Entities::Namespaces,
              failure:  [
                [401, "Authentication fails."],
                [403, "Authorization fails."],
                [404, "Not found."]
              ]

            get do
              team = Team.find params[:id]
              authorize team, :show?
              present team.namespaces, with: API::Entities::Namespaces, type: current_type
            end
          end

          resource :members do
            desc "Returns the list of team members",
              params:   API::Entities::Teams.documentation.slice(:id),
              is_array: true,
              entity:   API::Entities::Users,
              failure:  [
                [401, "Authentication fails."],
                [403, "Authorization fails."],
                [404, "Not found."]
              ]

            get do
              team = Team.find params[:id]
              authorize team, :member?
              present team.users, with: API::Entities::Users
            end
          end

          desc "Show teams by id.",
            entity:  API::Entities::Teams,
            failure: [
              [401, "Authentication fails."],
              [403, "Authorization fails."],
              [404, "Not found."]
            ]

          params do
            requires :id, type: String, documentation: { desc: "Team ID." }
          end

          get do
            team = Team.find(params[:id])
            authorize team, :show?
            present team, with: API::Entities::Teams
          end
        end
      end
    end
  end
end
