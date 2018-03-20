# frozen_string_literal: true

module API
  module V1
    # Registries implements all the endpoints regarding registries.
    class Registries < Grape::API
      version "v1", using: :path

      resource :registries do
        before do
          authorization!(force_admin: true)
        end

        desc "Returns a list of registries",
             tags:     ["registries"],
             detail:   "This will expose all accessible registries",
             is_array: true,
             entity:   API::Entities::Registries,
             failure:  [
               [401, "Authentication fails"],
               [403, "Authorization fails"]
             ]

        get do
          present Registry.all, with: API::Entities::Registries
        end

        desc "Create a registry",
             tags:     ["registries"],
             detail:   "Allow users to create a registry. " \
                       "This will only work if no registry works yet",
             entity:   API::Entities::Registries,
             consumes: ["application/x-www-form-urlencoded", "application/json"],
             failure:  [
               [400, "Bad request", API::Entities::ApiErrors],
               [401, "Authentication fails"],
               [403, "Authorization fails"],
               [422, "Unprocessable Entity", API::Entities::FullApiErrors]
             ]

        params do
          requires :registry, type: Hash do
            requires :all,
                     only:  %i[name hostname use_ssl],
                     using: API::Entities::Registries.documentation.slice(
                       :name, :hostname, :use_ssl
                     )
            optional :all,
                     only:  %i[use_ssl external_hostname],
                     using: API::Entities::Registries.documentation.slice(:external_hostname)
          end
        end

        post do
          svc = ::Registries::CreateService.new(current_user, permitted_params[:registry])
          obj = svc.execute

          if svc.valid?
            present obj, with: API::Entities::Registries
          else
            unprocessable_entity!(svc.messages)
          end
        end

        desc "Update registry",
             params:   API::Entities::Registries.documentation.slice(:id),
             failure:  [
               [400, "Bad request", API::Entities::ApiErrors],
               [401, "Authentication fails"],
               [403, "Authorization fails"],
               [404, "Not found"],
               [422, "Unprocessable Entity", API::Entities::FullApiErrors]
             ],
             entity:   API::Entities::Registries,
             consumes: ["application/x-www-form-urlencoded", "application/json"]

        params do
          requires :registry, type: Hash do
            optional :all,
                     only:  %i[name hostname use_ssl external_hostname],
                     using: API::Entities::Registries.documentation.slice(
                       :name, :hostname, :use_ssl, :external_hostname
                     )
          end
        end

        put ":id" do
          attrs = declared(params, include_missing: false)[:registry].merge(id: params[:id])
          svc = ::Registries::UpdateService.new(current_user, attrs)
          obj = svc.execute

          if svc.valid?
            present obj, with: API::Entities::Registries
          else
            unprocessable_entity!(svc.messages)
          end
        end

        desc "Validates the given registry",
             tags:     ["registries"],
             detail:   "Besides containing the usual Status object, it adds the reachable " \
                       "validation to the `hostname` field in the `messages` hash. This " \
                       "validation returns a string containing the error as given by the " \
                       "registry. If empty then everything went well",
             entity:   API::Entities::Status,
             consumes: ["application/x-www-form-urlencoded", "application/json"],
             failure:  [
               [401, "Authentication fails"],
               [403, "Authorization fails"]
             ]

        params do
          requires :name,
                   using: API::Entities::Registries.documentation.slice(:name)
          requires :hostname,
                   using: API::Entities::Registries.documentation.slice(:hostname)
          optional :external_hostname,
                   using: API::Entities::Registries.documentation.slice(:external_hostname)
          requires :use_ssl,
                   using: API::Entities::Registries.documentation.slice(:use_ssl)
          optional :only,
                   documentation: { desc: "Restrict which parameters are to be validated" },
                   type:          Array[String]
        end

        get "/validate" do
          validation = ::Registries::ValidateService.new(permitted_params).execute
          present validation, with: API::Entities::Status
        end
      end
    end
  end
end
