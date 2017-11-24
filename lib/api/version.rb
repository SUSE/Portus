module API
  class Version < Grape::API
    before do
      authorization!(force_admin: false)
    end

    desc "Fetch the version of Portus",
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

      {
        "api-versions": ["v1"],
        git:            git,
        version:        version
      }
    end
  end
end
