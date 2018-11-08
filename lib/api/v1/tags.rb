# frozen_string_literal: true

module API
  module V1
    # Tags implements all the endpoints regarding tags that have not been
    # addressed in other classes.
    class Tags < Grape::API
      include PaginationParams
      include OrderingParams

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

        params do
          use :pagination
          use :ordering
        end

        get do
          raise Pundit::NotAuthorizedError unless @user.admin?

          present paginate(order(Tag.all)), with: API::Entities::Tags
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

          desc "Delete tag",
               params:  API::Entities::Tags.documentation.slice(:id),
               failure: [
                 [401, "Authentication fails"],
                 [403, "Authorization fails"],
                 [404, "Not found"],
                 [422, "Unprocessable Entity", API::Entities::ApiErrors]
               ]

          delete do
            tag = Tag.find(params[:id])
            authorize tag, :destroy?

            service = ::Tags::DestroyService.new(current_user)
            destroyed = service.execute(tag)

            if destroyed
              status 204
            else
              unprocessable_entity!(service.error)
            end
          end
        end
      end
    end
  end
end
