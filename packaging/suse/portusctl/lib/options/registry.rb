module Portusctl
  module Options
    module Registry
      def self.included(thor)
        thor.class_eval do
          # Registry
          option "local-registry", desc: "Configure Docker registry running locally",
                 type: :boolean, default: false

          # JWT expiration time.
          option "jwt-expiration-time",
                 desc:    "Expiration time for the JWT token used by Portus",
                 default: 5

          # Catalog pagination
          option "catalog-page",
                 desc:    "Pagination value for API calls to the registry",
                 default: 100

          # Delete images/tags
          option "delete-enable",
                 desc:    "Enable delete support. Only do this if your registry is 2.4 or higher",
                 type:    :boolean,
                 default: false
        end
      end
    end
  end
end
