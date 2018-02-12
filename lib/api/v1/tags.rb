# frozen_string_literal: true

module API
  module V1
    # Tags implements all the endpoints regarding tags that have not been
    # addressed in other classes.
    class Tags < Grape::API
      version "v1", using: :path

      resource :tags do
        before do
          authorization!(force_admin: false)
        end

        desc "Returns list of tags",
             tags:     ["tags"],
             detail:   "This will expose all tags",
             is_array: true,
             entity:   API::Entities::Tags,
             failure:  [
               [401, "Authentication fails"],
               [403, "Authorization fails"]
             ]

        get do
          raise Pundit::NotAuthorizedError unless @user.admin?
          present Tag.all, with: API::Entities::Tags
        end

        route_param :id, type: Integer, requirements: { id: /.*/ } do
          desc "Show tag by id",
               entity:  API::Entities::Tags,
               failure: [
                 [401, "Authentication fails"],
                 [403, "Authorization fails"],
                 [404, "Not found"]
               ]

          params do
            requires :id, type: Integer, documentation: { desc: "Tag ID" }
          end

          get do
            tag = Tag.find(params[:id])
            authorize tag, :show?
            present tag, with: API::Entities::Tags
          end
        end
      end
    end
  end
end
