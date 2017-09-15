module API
  module V1
    class Namespaces < Grape::API
      version "v1", using: :path

      resource :namespaces do
        before do
          authorization!(force_admin: false)
        end

        helpers do
          def accessible_namespaces
            special = Namespace.special_for(current_user).order(created_at: :asc)
            normal  = policy_scope(Namespace).order(created_at: :asc)
            special + normal
          end
        end

        desc "Returns a list of namespaces.",
          tags:     ["namespaces"],
          detail:   "This will expose all accessible namespaces.",
          is_array: true,
          entity:   API::Entities::Namespaces,
          failure:  [
            [401, "Authentication fails."],
            [403, "Authorization fails."]
          ]

        get do
          present accessible_namespaces, with: API::Entities::Namespaces
        end

        route_param :id, type: String, requirements: { id: /.*/ } do
          resource :repositories do
            desc "Returns the list of the repositories for the given namespace.",
              params:   API::Entities::Namespaces.documentation.slice(:id),
              is_array: true,
              entity:   API::Entities::Repositories,
              failure:  [
                [401, "Authentication fails."],
                [403, "Authorization fails."],
                [404, "Not found."]
              ]

            get do
              namespace = Namespace.find params[:id]
              authorize namespace, :show?
              present namespace.repositories, with: API::Entities::Repositories
            end
          end

          desc "Show namespaces by id.",
            entity:  API::Entities::Namespaces,
            failure: [
              [401, "Authentication fails."],
              [403, "Authorization fails."],
              [404, "Not found."]
            ]

          params do
            requires :id, type: String, documentation: { desc: "Namespace ID." }
          end

          get do
            namespace = Namespace.find(params[:id])
            authorize namespace, :show?
            present namespace, with: API::Entities::Namespaces
          end
        end
      end
    end
  end
end
