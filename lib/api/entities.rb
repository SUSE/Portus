# frozen_string_literal: true

module API
  # Entities is a module that groups all the classes to be used as Grape
  # entities.
  module Entities
    # General entities

    class ApiErrors < Grape::Entity
      expose :errors, documentation: {
        type: "API::Entities::Messages", is_array: true
      }
    end

    class Messages < Grape::Entity
      expose :message
    end

    # Messages for /validate calls.
    class Status < Grape::Entity
      expose :messages, documentation: {
        type: Hash,
        desc: "Detailed hash with the fields"
      }

      expose :valid, documentation: {
        type: "Boolean",
        desc: "Whether the given resource is valid or not"
      }
    end

    # Users and application tokens

    class Users < Grape::Entity
      expose :id, documentation: { type: Integer, desc: "User ID" }
      expose :username, documentation: { type: String, desc: "User name" }
      expose :email, documentation: { type: String, desc: "E-mail" }
      expose :current_sign_in_at, documentation: { type: DateTime }
      expose :last_sign_in_at, documentation: { type: DateTime }
      expose :created_at, :updated_at, documentation: { type: DateTime }
      expose :admin, :enabled, documentation: { type: "boolean" }
      expose :locked_at, documentation: { type: DateTime }
      expose :namespace_id, documentation: { type: Integer }
      expose :display_name, documentation: { type: String, desc: "Display name" }
    end

    class ApplicationTokens < Grape::Entity
      expose :id, unless: { type: :create }, documentation: { type: Integer }
      expose :application, unless: { type: :create }
      expose :plain_token, if: { type: :create }
    end

    # Registry

    class Registries < Grape::Entity
      expose :id, unless: { type: :create }, documentation: { type: Integer }
      expose :name, documentation: {
        type: String,
        desc: "The name of the registry"
      }
      expose :hostname, documentation: {
        type: String,
        desc: "The hostname of the registry"
      }
      expose :external_hostname, documentation: {
        type: String,
        desc: "An external hostname of the registry, useful if behind a proxy with a different FQDN"
      }
      expose :use_ssl, documentation: {
        type: ::Grape::API::Boolean,
        desc: "Whether the registry uses SSL or not"
      }
      expose :created_at, :updated_at, documentation: { type: DateTime }
    end

    # Repositories and tags

    class Tags < Grape::Entity
      expose :id, documentation: { type: Integer, desc: "Tag ID" }
      expose :name, documentation: { type: String, desc: "Tag name" }
      expose :author, documentation: {
        type: Integer,
        desc: "The ID of the user that pushed this tag"
      } do |t|
        { id: t.author&.id, name: t.author&.username }
      end
      expose :digest, documentation: { type: String, desc: "The digest of the tag" }
      expose :image_id, documentation: { type: String, desc: "The internal image ID" }
      expose :created_at, :updated_at, documentation: { type: DateTime }
      expose :scanned, documentation: {
        type: Integer,
        desc: "Whether vulnerabilities have been scanned or not. The values available are: " \
              "0 (not scanned), 1 (work in progress) and 2 (scanning done)."
      }
      expose :vulnerabilities, documentation: {
        is_array: true,
        desc:     "An array of vulnerabilities for this tag, or null if the feature is not enabled"
      }
    end

    class Repositories < Grape::Entity
      expose :id, documentation: { type: Integer, desc: "Repository ID" }
      expose :name, documentation: { type: String, desc: "Repository name" }
      expose :full_name, documentation: { type: String, desc: "Repository full name" }
      expose :created_at, :updated_at, documentation: { type: DateTime }
      expose :namespace, documentation: {
        desc: "The ID of the namespace containing this repository"
      } do |r|
        { id: r.namespace.id, name: r.namespace.name }
      end
      expose :registry_hostname, documentation: {
        type: Integer,
        desc: "The repository's registry hostname"
      }, if: { type: :internal } do |repository|
        repository.registry.hostname
      end
      expose :stars, documentation: {
        type: Integer,
        desc: "The number of stars for this repository"
      } do |repository|
        repository.stars.count
      end
      expose :tags_count, documentation: {
        type: Integer,
        desc: "The number of tags for this repository"
      } do |repository|
        repository.tags.count
      end
      expose :tags, documentation: {
        is_array: true,
        desc:     "The repository's tags grouped by digest"
      }, if: { type: :internal } do |repository|
        repository.groupped_tags.map do |k1|
          API::Entities::Tags.represent(k1)
        end
      end
    end

    # Teams & namespaces

    class Teams < Grape::Entity
      expose :id, documentation: { type: Integer, desc: "Repository ID" }
      expose :name, documentation: { type: String, desc: "Repository name" }
      expose :created_at, :updated_at, documentation: { type: DateTime }
      expose :hidden, :updated_at, documentation: {
        type: "Boolean",
        desc: "Whether the team is visible to the final user or not"
      }
      expose :role, documentation: {
        type: String,
        desc: "The role this of the current user within this team"
      }, if: { type: :internal } do |team, options|
        user = options[:current_user]

        # TODO: partially taken from TeamsHelper. Avoid duplication!
        team_user = team.team_users.find_by(user_id: user.id)
        team_user&.role&.titleize
      end
      expose :users_count, documentation: {
        type: Integer,
        desc: "The number of enabled users that belong to this team"
      }, if: { type: :internal } do |t|
        t.users.enabled.count
      end
      expose :namespaces_count, documentation: {
        type: Integer,
        desc: "The number of namespaces that belong to this team"
      }, if: { type: :internal } do |t|
        t.namespaces.count
      end
    end

    class Namespaces < Grape::Entity
      expose :id, documentation: { type: Integer, desc: "Namespace ID" }
      expose :clean_name, as: :name, documentation: { type: String, desc: "Namespace name" }
      expose :created_at, :updated_at, documentation: { type: DateTime }
      expose :description, documentation: {
        type: String,
        desc: "The description of the namespace"
      }
      expose :team_name, documentation: {}, if: { type: :internal } do |n|
        n.team.name
      end
      expose :team_id, documentation: {
        type: Integer,
        desc: "The ID of the team containing this namespace"
      }
      expose :repositories_count, documentation: {
        type: Integer,
        desc: "The number of repositories that belong to this namespace"
      }, if: { type: :internal } do |n|
        n.repositories.count
      end
      expose :webhooks_count, documentation: {
        type: Integer,
        desc: "The number of webooks that belong to this namespace"
      }, if: { type: :internal } do |n|
        n.webhooks.count
      end
      expose :visibility, documentation: {
        type: String,
        desc: "The visibility of namespaces by other people"
      } do |namespace|
        namespace.visibility.to_s.gsub("visibility_", "")
      end
      expose :global, documentation: {
        type: "Boolean",
        desc: "Whether this is the global namespace or not"
      }
      expose :permissions, documentation: {
        desc: "Different permissions for the current user"
      }, if: { type: :internal } do |namespace, options|
        user = options[:current_user]
        # TODO: taken from NamespacesHelper. Avoid duplication! (e.g. owner?)
        {
          webhooks:   user.admin? ||
            namespace.team.users.include?(user),
          visibility: user.admin? ||
            (namespace.team.owners.exists?(user.id) &&
              APP_CONFIG.enabled?("user_permission.change_visibility"))
        }
      end
    end

    class Version < Grape::Entity
      expose :"api-versions", documentation: {
        type: "Array[String]",
        desc: "Versions of the API supported"
      }
      expose :git, documentation: { type: String, desc: "Git information" }
      expose :version, documentation: { type: String, desc: "Version of Portus" }
    end

    class Health < Grape::Entity
      class HealthStatus < Grape::Entity
        expose :msg, documentation: { type: String, desc: "Description message" }
        expose :success, documentation: {
          type: "Boolean",
          desc: "Whether health checking was successful or not for the component"
        }
      end

      expose :database, documentation: { type: HealthStatus, desc: "Database health status" }
      expose :registry, documentation: { type: HealthStatus, desc: "Registry health status" }
      expose :clair, documentation: {
        type: HealthStatus,
        desc: "CoreOS Clair health status. Empty if Clair support has not been enabled"
      }
    end
  end
end
