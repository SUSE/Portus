module API
  module V1
    class Registries < Grape::API
      version "v1", using: :path

      resource :registries do
        before do
          authorization!(force_admin: true)
        end

        desc "Returns a list of registries",
        tags:     ["registries"],
        detail:   "This will expose all accessible registries.",
        is_array: true,
        entity:   API::Entities::Registries,
        failure:  [
          [401, "Authentication fails."],
          [403, "Authorization fails."]
        ]

        get do
          present Registry.all, with: API::Entities::Registries
        end

        desc "Validates the given registry",
          tags:    ["registries"],
          detail:  "Besides containing the usual Status object, it adds a `reachable` " \
                   "field in the `messages` hash. This field is a string containing the error " \
                   "as given by the registry. If empty then everything went well",
          entity:  API::Entities::Status,
          failure: [
            [401, "Authentication fails."],
            [403, "Authorization fails."]
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
        end

        get "/validate" do
          r         = Registry.new(permitted_params)
          valid     = r.valid?
          reachable = r.reachable?
          fields    = r.errors.messages.merge(reachable: reachable)
          obj       = { valid: valid && reachable, messages: fields }
          present obj, with: API::Entities::Status
        end
      end
    end
  end
end
