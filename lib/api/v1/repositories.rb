# frozen_string_literal: true

module API
  module V1
    # Repositories implements all the endpoints regarding repositories and some
    # endpoints regarding tags that might be convenient to use as a
    # sub-resource.
    class Repositories < Grape::API
      version "v1", using: :path

      resource :repositories do
        before do
          authorization!(force_admin: false)
        end

        desc "Returns list of repositories",
             tags:     ["repositories"],
             detail:   "This will expose all repositories",
             is_array: true,
             entity:   API::Entities::Repositories,
             failure:  [
               [401, "Authentication fails"],
               [403, "Authorization fails"]
             ]

        get do
          present policy_scope(Repository), with: API::Entities::Repositories, type: current_type
        end

        route_param :id, type: String, requirements: { id: /.*/ } do
          resource :tags do
            desc "Returns the list of the tags for the given repository",
                 params:   API::Entities::Repositories.documentation.slice(:id),
                 is_array: true,
                 entity:   API::Entities::Tags,
                 failure:  [
                   [401, "Authentication fails"],
                   [403, "Authorization fails"],
                   [404, "Not found"]
                 ]

            get do
              repo = Repository.find params[:id]
              authorize repo, :show?
              present repo.tags, with: API::Entities::Tags
            end

            desc "Returns the list of the tags for the given repository groupped by digest",
                 params:   API::Entities::Repositories.documentation.slice(:id),
                 is_array: true,
                 entity:   API::Entities::Tags,
                 failure:  [
                   [401, "Authentication fails"],
                   [403, "Authorization fails"],
                   [404, "Not found"]
                 ]

            get "/grouped" do
              repo = Repository.find params[:id]
              authorize repo, :show?

              grouped_tags = repo.groupped_tags.map do |k1|
                API::Entities::Tags.represent(k1)
              end
              present grouped_tags
            end

            # NOTE: (for v2 ?) the repository ID is ignored...
            route_param :tag_id, type: String, requirements: { tag_id: /.*/ } do
              desc "Show tag by id",
                   entity:  API::Entities::Tags,
                   failure: [
                     [401, "Authentication fails"],
                     [403, "Authorization fails"],
                     [404, "Not found"]
                   ]

              params do
                requires :id, using: API::Entities::Repositories.documentation.slice(:id)
                requires :tag_id, type: String, documentation: { desc: "Tag ID" }
              end

              get do
                tag = Tag.find(params[:tag_id])
                authorize tag, :show?
                present tag, with: API::Entities::Tags
              end
            end
          end

          desc "Show repositories by id",
               entity:  API::Entities::Repositories,
               failure: [
                 [401, "Authentication fails"],
                 [403, "Authorization fails"],
                 [404, "Not found"]
               ]

          params do
            requires :id, using: API::Entities::Repositories.documentation.slice(:id)
          end

          get do
            repo = Repository.find(params[:id])
            authorize repo, :show?
            present repo, with: API::Entities::Repositories, type: current_type
          end
        end
      end
    end
  end
end
