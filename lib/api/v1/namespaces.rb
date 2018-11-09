# frozen_string_literal: true

module API
  module V1
    # Namespaces implements all the endpoints regarding namespaces.
    class Namespaces < Grape::API
      include PaginationParams
      include OrderingParams

      version "v1", using: :path

      resource :namespaces do
        before do
          authorization!(force_admin: false)
        end

        desc "Returns a list of namespaces",
             tags:     ["namespaces"],
             detail:   "This will expose all accessible namespaces by the user via either team
                        membership or visibility. Keep in mind that if the user is an admin, this
                        will return all the global, personal and other namespaces created by all
                        the users",
             is_array: true,
             entity:   API::Entities::Namespaces,
             failure:  [
               [401, "Authentication fails"],
               [403, "Authorization fails"]
             ]

        params do
          use :pagination
          use :ordering
        end

        get do
          namespaces = paginate(order(policy_scope(Namespace)))
          present namespaces,
                  with:         API::Entities::Namespaces,
                  current_user: current_user,
                  type:         current_type
        end

        desc "Validates the given namespace",
             tags:    ["namespaces"],
             detail:  "Validates the given namespace",
             entity:  API::Entities::Status,
             failure: [
               [401, "Authentication fails"],
               [403, "Authorization fails"]
             ]

        params do
          requires :name, type: String, documentation: { desc: "Name to be checked" }
        end

        get "/validate" do
          namespace = Namespace.new(name: params[:name], registry: Registry.get)
          valid = namespace.valid?
          obj = { valid: valid, messages: namespace.errors.messages }
          present obj, with: API::Entities::Status
        end

        desc "Create a namespace",
             entity:   API::Entities::Teams,
             consumes: ["application/x-www-form-urlencoded", "application/json"],
             failure:  [
               [400, "Bad request", API::Entities::ApiErrors],
               [401, "Authentication fails"],
               [403, "Authorization fails"],
               [422, "Unprocessable Entity", API::Entities::FullApiErrors]
             ]

        params do
          requires :name, type: String, documentation: { desc: "Namespace name" }
          requires :team, type: String, documentation: { desc: "Team name" }
          optional :description, type: String, documentation: { desc: "Team description" }
        end

        post do
          namespace = ::Namespaces::BuildService.new(current_user, permitted_params).execute
          authorize namespace, :create?

          namespace = ::Namespaces::CreateService.new(current_user, namespace).execute

          if namespace.valid?
            present namespace,
                    with:         API::Entities::Namespaces,
                    current_user: current_user,
                    type:         current_type
          else
            unprocessable_entity!(namespace.errors)
          end
        end

        # Update namespace with given :id.
        desc "Update namespace",
             params:   API::Entities::Namespaces.documentation.slice(:id),
             failure:  [
               [400, "Bad request", API::Entities::ApiErrors],
               [401, "Authentication fails"],
               [403, "Authorization fails"],
               [404, "Not found"],
               [422, "Unprocessable Entity", API::Entities::FullApiErrors]
             ],
             consumes: ["application/x-www-form-urlencoded", "application/json"]

        params do
          requires :namespace, type: Hash do
            optional :all,
                     only:  [:name],
                     using: API::Entities::Namespaces.documentation.slice(:name)
            optional :all,
                     only:  [:description],
                     using: API::Entities::Namespaces.documentation.slice(:description)
            optional :all,
                     only:  [:team],
                     using: API::Entities::Namespaces.documentation.slice(:team)
            optional :all,
                     only:  [:visibility],
                     using: API::Entities::Namespaces.documentation.slice(:visibility)
          end
        end

        put ":id" do
          attrs = permitted_params.merge(id: params[:id])
          ns = ::Namespaces::UpdateService.new(current_user, attrs)
          namespace = ns.build

          authorize namespace, :update?
          authorize namespace, :change_team? if ns.wants_to_change_team?
          authorize namespace, :change_visibility? if ns.wants_to_change_visibility?

          if ns.execute
            present namespace.reload,
                    with:         API::Entities::Namespaces,
                    current_user: current_user,
                    type:         current_type
          else
            unprocessable_entity!(namespace.errors.messages)
          end
        end

        desc "Delete namespace",
             params:  API::Entities::Namespaces.documentation.slice(:id),
             failure: [
               [401, "Authentication fails"],
               [403, "Authorization fails"],
               [404, "Not found"],
               [422, "Unprocessable Entity", API::Entities::ApiErrors]
             ]

        delete ":id" do
          namespace = Namespace.find(params[:id])
          authorize namespace, :destroy?

          service = ::Namespaces::DestroyService.new(current_user)
          destroyed = service.execute(namespace)

          destroyed ? status(204) : unprocessable_entity!(service.error)
        end

        route_param :id, type: Integer, requirements: { id: /.*/ } do
          resource :repositories do
            desc "Returns the list of the repositories for the given namespace",
                 params:   API::Entities::Namespaces.documentation.slice(:id),
                 is_array: true,
                 entity:   API::Entities::Repositories,
                 failure:  [
                   [401, "Authentication fails"],
                   [403, "Authorization fails"],
                   [404, "Not found"]
                 ]

            get do
              namespace = Namespace.find params[:id]
              authorize namespace, :show?
              present namespace.repositories,
                      with: API::Entities::Repositories,
                      type: current_type
            end
          end

          desc "Show namespaces by id",
               entity:  API::Entities::Namespaces,
               failure: [
                 [401, "Authentication fails"],
                 [403, "Authorization fails"],
                 [404, "Not found"]
               ]

          params do
            requires :id, type: Integer, documentation: { desc: "Namespace ID" }
          end

          get do
            namespace = Namespace.find(params[:id])
            authorize namespace, :show?
            present namespace,
                    with:         API::Entities::Namespaces,
                    current_user: current_user,
                    type:         current_type
          end
        end
      end
    end
  end
end
