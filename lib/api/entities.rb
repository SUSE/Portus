require "api/helpers"

module API
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
      } { |t| { id: t.author.id, name: t.author.username } }
      expose :digest, documentation: { type: String, desc: "The digest of the tag" }
      expose :image_id, documentation: { type: String, desc: "The internal image ID" }
      expose :created_at, :updated_at, documentation: { type: DateTime }
      expose :vulnerabilities, documentation: {
        is_array: true,
        desc:     "An array of vulnerabilities for this tag, or null if the feature is not enabled"
      }
    end

    class Repositories < Grape::Entity
      expose :id, documentation: { type: Integer, desc: "Repository ID" }
      expose :name, documentation: { type: String, desc: "Repository name" }
      # rubocop:disable Style/SymbolProc
      expose :full_name, documentation: { type: String, desc: "Repository full name" } do |r|
        r.full_name
      end
      # rubocop:enable Style/SymbolProc
      expose :created_at, :updated_at, documentation: { type: DateTime }
      expose :namespace, documentation: {
        desc: "The ID of the namespace containing this repository"
      } { |r| { id: r.namespace.id, name: r.namespace.name } }
      expose :registry_hostname, documentation: {
        type: Integer,
        desc: "The repository's registry hostname"
      }, if: { type: :internal } { |repository| repository.registry.hostname }
      expose :stars, documentation: {
        type: Integer,
        desc: "The number of stars for this repository"
      } { |repository| repository.stars.count }
      expose :tags_count, documentation: {
        type: Integer,
        desc: "The number of tags for this repository"
      } { |repository| repository.tags.count }
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
      include ::API::Helpers::Teams

      expose :id, documentation: { type: Integer, desc: "Repository ID" }
      expose :name, documentation: { type: String, desc: "Repository name" }
      expose :created_at, :updated_at, documentation: { type: DateTime }
      expose :description, documentation: {
        type: String,
        desc: "The description of the team"
      }
      expose :hidden, :updated_at, documentation: {
        type: "Boolean",
        desc: "Whether the team is visible to the final user or not"
      }
      expose :role, documentation: {
        type: String,
        desc: "The role this of the current user within this team"
      }, if: { type: :internal } { |team, options| role_within_team(options[:current_user], team) }
      expose :users_count, documentation: {
        type: Integer,
        desc: "The number of enabled users that belong to this team"
      }, if: { type: :internal } { |t| t.users.enabled.count }
      expose :namespaces_count, documentation: {
        type: Integer,
        desc: "The number of namespaces that belong to this team"
      }, if: { type: :internal } { |t| t.namespaces.count }
    end

    class Namespaces < Grape::Entity
      expose :id, documentation: { type: Integer, desc: "Namespace ID" }
      expose :clean_name, as: :name, documentation: { type: String, desc: "Namespace name" }
      expose :created_at, :updated_at, documentation: { type: DateTime }
      expose :description, documentation: {
        type: String,
        desc: "The description of the namespace"
      }
      expose :team, documentation: {
        desc: "The ID and the name of the team containing this namespace"
      } { |namespace| namespace.team.slice("id", "name") }
      expose :team_name, documentation: {
      }, if: { type: :internal } { |n| n.team.name }
      expose :team_id, documentation: {
        type: Integer,
        desc: "The ID of the team containing this namespace"
      }
      expose :repositories_count, documentation: {
        type: Integer,
        desc: "The number of repositories that belong to this namespace"
      }, if: { type: :internal } { |n| n.repositories.count }
      expose :webhooks_count, documentation: {
        type: Integer,
        desc: "The number of webooks that belong to this namespace"
      }, if: { type: :internal } { |n| n.webhooks.count }
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
  end
end
