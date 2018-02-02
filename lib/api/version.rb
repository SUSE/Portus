# frozen_string_literal: true

module API
  # Version implements the main "/version" endpoint. It's not versioned because
  # this is meant to be stable throughout any version of the API.
  class Version < Grape::API
    before do
      authorization!(force_admin: false)
    end

    desc "Fetch the version of Portus",
         entity: API::Entities::Version,
         tags:   ["version"],
         detail: "Returns the version of Portus and the supported API versions"

    get "/version" do
      version = ::Version.from_file
      git = if ::Version.git?
              if ::Version::TAG.present?
                { tag: ::Version::TAG }
              else
                { branch: ::Version::BRANCH, commit: ::Version::COMMIT }
              end
            end

      obj = { "api-versions": ["v1"], git: git, version: version }
      present obj, with: API::Entities::Version, type: current_type
    end
  end
end
