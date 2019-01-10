# frozen_string_literal: true

module API
  module V1
    class Teams < Grape::API
      include PaginationParams
      include OrderingParams

      version "v1", using: :path

      resource :teams do
        before do
          authorization!(force_admin: false)
        end

        desc "Returns list of teams",
             tags:     ["teams"],
             detail:   "This will expose all teams that the user is member of or has access to.
                        That mean if the user is an admin, this will return all the teams created by
                        all the users. If you want to check if the user is a member of a team, check
                        the role attribute.",
             is_array: true,
             entity:   API::Entities::Teams,
             failure:  [
               [401, "Authentication fails"],
               [403, "Authorization fails"]
             ]

        params do
          use :pagination
          use :ordering
        end

        get do
          teams = paginate(order(policy_scope(Team)))
          present teams, with: API::Entities::Teams, type: current_type
        end

        desc "Create a team",
             entity:   API::Entities::Teams,
             consumes: ["application/x-www-form-urlencoded", "application/json"],
             failure:  [
               [400, "Bad request", API::Entities::ApiErrors],
               [401, "Authentication fails"],
               [403, "Authorization fails"],
               [422, "Unprocessable Entity", API::Entities::FullApiErrors]
             ]

        params do
          requires :name, type: String, documentation: { desc: "Team name" }
          optional :description, type: String, documentation: { desc: "Team description" }
          optional :owner_id, type: Integer, documentation: { desc: "Team owner" }
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
            unprocessable_entity!(team.errors)
          end
        end

        # Update team with given :id.
        desc "Update team",
             params:   API::Entities::Teams.documentation.slice(:id),
             failure:  [
               [400, "Bad request", API::Entities::ApiErrors],
               [401, "Authentication fails"],
               [403, "Authorization fails"],
               [404, "Not found"],
               [422, "Unprocessable Entity", API::Entities::FullApiErrors]
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
            present team.reload,
                    with:         API::Entities::Teams,
                    current_user: current_user,
                    type:         current_type
          else
            unprocessable_entity!(team.errors.messages)
          end
        end

        desc "Deletes a team",
             entity:  API::Entities::Teams,
             failure: [
               [400, "Unprocessable Entity", API::Entities::ApiErrors],
               [401, "Authentication fails"],
               [403, "Authorization fails"],
               [404, "Not found"],
               [422, "Unprocessable Entity", API::Entities::ApiErrors]
             ]

        params do
          requires :id, documentation: { desc: "Team id" }
          optional :new_team, documentation: { desc: "Team that will get the original namespaces
            from the deleted team" }
        end

        delete ":id" do
          team = Team.find_by!(id: params[:id])
          new_team = Team.find_by!(name: params[:new_team]) if params[:new_team].present?
          authorize team, :destroy?

          svc = ::Teams::DestroyService.new(current_user)
          destroyed = svc.execute(team, new_team)

          if destroyed
            status 204
          else
            unprocessable_entity!(svc.error)
          end
        end

        desc "Disables any LDAP check for the team",
             params:   API::Entities::Teams.documentation.slice(:id),
             failure:  [
               [400, "Bad request", API::Entities::ApiErrors],
               [401, "Authentication fails"],
               [403, "Authorization fails"],
               [404, "Not found"],
               [405, "Method Not Allowed", API::Entities::ApiErrors]
             ],
             consumes: ["application/x-www-form-urlencoded", "application/json"]

        params do
          requires :id, documentation: { desc: "Team id" }
        end

        post ":id/ldap_check" do
          if APP_CONFIG.disabled?("ldap") || APP_CONFIG.disabled?("ldap.group_sync")
            method_not_allowed!("this instance has disabled this endpoint")
          else
            attrs = permitted_params.merge(id: params[:id])
            team = Team.find(attrs[:id])
            authorize team, :update?

            team.update!(ldap_group_checked: Team.ldap_statuses[:disabled])
            status :ok
          end
        end

        route_param :id, type: String, requirements: { id: /.*/ } do
          resource :namespaces do
            desc "Returns the list of namespaces for the given team",
                 params:   API::Entities::Teams.documentation.slice(:id),
                 is_array: true,
                 entity:   API::Entities::Namespaces,
                 failure:  [
                   [401, "Authentication fails"],
                   [403, "Authorization fails"],
                   [404, "Not found"]
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
                   [401, "Authentication fails"],
                   [403, "Authorization fails"],
                   [404, "Not found"]
                 ]

            get do
              team = Team.find params[:id]
              authorize team, :member?
              present team.users, with: API::Entities::Users
            end

            desc "Deletes a member from a team",
                 entity:  API::Entities::TeamMembers,
                 failure: [
                   [400, "Unprocessable Entity", API::Entities::ApiErrors],
                   [401, "Authentication fails"],
                   [403, "Authorization fails"],
                   [404, "Not found"],
                   [422, "Unprocessable Entity", API::Entities::ApiErrors]
                 ]

            params do
              requires :id, documentation: { desc: "Team id" }
              requires :member_id, documentation: { desc: "Team member id" }
            end

            delete ":member_id" do
              team_user = TeamUser.find_by!(id: params[:member_id], team_id: params[:id])
              authorize team_user, :destroy?

              svc = ::TeamUsers::DestroyService.new(current_user)
              destroyed = svc.execute(team_user)

              if destroyed
                status 204
              else
                unprocessable_entity!(svc.message)
              end
            end

            desc "Updates a member from a team",
                 entity:  API::Entities::TeamMembers,
                 failure: [
                   [400, "Unprocessable Entity", API::Entities::ApiErrors],
                   [401, "Authentication fails"],
                   [403, "Authorization fails"],
                   [404, "Not found"],
                   [422, "Unprocessable Entity", API::Entities::ApiErrors]
                 ]

            params do
              requires :id, documentation: { desc: "Team id" }
              requires :member_id, type: Integer, documentation: { desc: "Team member id" }
              requires :role, type: String, documentation: { desc: "Team member role" }
            end

            put ":member_id" do
              team_user = TeamUser.find_by!(id: params[:member_id], team_id: params[:id])
              authorize team_user, :update?

              svc = ::TeamUsers::UpdateService.new(current_user, permitted_params)
              updated = svc.execute(team_user)

              if updated
                present team_user,
                        with:         API::Entities::TeamMembers,
                        current_user: current_user,
                        type:         current_type
              else
                unprocessable_entity!(svc.message)
              end
            end

            desc "Adds a user as member in a team",
                 entity:  API::Entities::TeamMembers,
                 failure: [
                   [401, "Authentication fails"],
                   [403, "Authorization fails"],
                   [404, "Not found"]
                 ]

            params do
              requires :id, documentation: { desc: "Team id" }
              requires :role, type: String, documentation: { desc: "Team member role" }
              requires :user, type: String, documentation: { desc: "Team member username" }
            end

            post do
              team_user = ::TeamUsers::BuildService.new(current_user, permitted_params).execute
              authorize team_user, :create?

              team_user = ::TeamUsers::CreateService.new(current_user, team_user).execute

              if team_user.valid? && team_user.persisted?
                present team_user,
                        with:         API::Entities::TeamMembers,
                        current_user: current_user,
                        type:         current_type
              else
                unprocessable_entity!(team_user.errors)
              end
            end
          end

          desc "Show teams by id",
               entity:  API::Entities::Teams,
               failure: [
                 [401, "Authentication fails"],
                 [403, "Authorization fails"],
                 [404, "Not found"]
               ]

          params do
            requires :id, type: String, documentation: { desc: "Team ID" }
          end

          get do
            team = Team.find(params[:id])
            authorize team, :show?
            present team, with: API::Entities::Teams, type: current_type
          end
        end
      end
    end
  end
end
