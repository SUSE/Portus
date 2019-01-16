# frozen_string_literal: true

require "api/helpers"

module API
  # Entities is a module that groups all the classes to be used as Grape
  # entities.
  module Entities
    # General entities

    class ApiErrors < Grape::Entity
      expose :message, documentation: {
        type: String,
        desc: "Error message"
      }
    end

    class FullApiErrors < Grape::Entity
      expose :message, documentation: {
        type: Hash,
        desc: "Detailed hash with the fields"
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
      expose :admin, :enabled, documentation: { type: ::Grape::API::Boolean }
      expose :locked_at, documentation: { type: DateTime }
      expose :namespace_id, documentation: { type: Integer }
      expose :display_name, documentation: { type: String, desc: "Display name" }
      expose :bot, documentation: {
        type: ::Grape::API::Boolean,
        desc: "Whether this is a bot or not"
      }
      expose :display_username, documentation: {
        type:   String,
        desc:   "Displayable name",
        hidden: true
      }, if: { type: :internal }
      expose :namespaces_count, documentation: {
        type:   Integer,
        desc:   "The number of namespaces that user has access to",
        hidden: true
      }, if: { type: :internal } do |u|
        u.teams.reduce(0) { |sum, t| sum + t.namespaces.count }
      end
      expose :teams_count, documentation: {
        type:   Integer,
        desc:   "The number of teams that the user belongs to",
        hidden: true
      }, if: { type: :internal } do |u|
        u.teams.all_non_special.count
      end
    end

    class ApplicationTokens < Grape::Entity
      expose :id, documentation: { type: Integer }
      expose :application, documentation: { type: String }
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
      expose :size, documentation: { type: Integer, desc: "The size of the tag" }
      expose :size_human, documentation: {
        type:   String,
        desc:   "The size of the tag for humans",
        hidden: true
      }, if: { type: :internal } do |tag|
        ActiveSupport::NumberHelper.number_to_human_size(tag.size) if tag.size
      end
      expose :scanned, documentation: {
        type: Integer,
        desc: "Whether vulnerabilities have been scanned or not. The values available are: " \
              "0 (not scanned), 1 (work in progress) and 2 (scanning done)."
      }
      # rubocop:disable Style/SymbolProc
      expose :vulnerabilities, documentation: {
        desc: "A hash of vulnerabilities for this tag, or null if the feature is not enabled"
      } do |tag|
        tag.fetch_vulnerabilities
      end
      # rubocop:enable Style/SymbolProc
    end

    class Repositories < Grape::Entity
      include ::API::Helpers

      expose :id, documentation: { type: Integer, desc: "Repository ID" }
      expose :name, documentation: { type: String, desc: "Repository name" }
      expose :full_name, documentation: { type: String, desc: "Repository full name" }
      expose :created_at, :updated_at, documentation: { type: DateTime }
      expose :description, documentation: {
        type: String,
        desc: "The description of the repository"
      }
      expose :description_md, documentation: {
        type:   String,
        desc:   "The description of the repository parsed by markdown",
        hidden: true
      }, if: { type: :internal } do |r|
        markdown(r.description)
      end
      expose :namespace, documentation: {
        desc: "The ID of the namespace containing this repository"
      } do |r|
        { id: r.namespace.id, name: r.namespace.name }
      end
      expose :registry_hostname, documentation: {
        type: Integer,
        desc: "The repository's registry hostname. Prioritizes external hostname value" \
              "if present, otherwise internal hostname is shown"
      }, if: :type do |repository|
        repository.registry.reachable_hostname
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
        desc:     "The repository's tags grouped by digest",
        hidden:   true
      }, if: { type: :search } do |repository|
        repository.groupped_tags.map do |k1|
          API::Entities::Tags.represent(k1)
        end
      end
      expose :starred, documentation: {
        desc: "Boolean that tells if the current user starred the repository"
      }, if: :type do |repository, options|
        repository.starred_by?(options[:current_user])
      end
      expose :destroyable, documentation: {
        desc: "Boolean that tells if the current user can destroy or not the repository"
      }, if: :type do |repository, options|
        user = options[:current_user]
        can_destroy_repository?(repository, user) if user
      end
    end

    class Comments < Grape::Entity
      include ::API::Helpers

      expose :id, documentation: { type: Integer, desc: "Comment ID" }
      expose :repository_id, documentation: { type: Integer, desc: "Repository ID" }
      expose :created_at, :updated_at, documentation: { type: DateTime }
      expose :body, documentation: {
        type: String,
        desc: "The body of the comment"
      }
      expose :body_md, documentation: {
        type:   String,
        desc:   "The body of the comment parsed by markdown",
        hidden: true
      }, if: { type: :internal } do |c|
        markdown(c.body)
      end
      expose :author, documentation: {
        desc: "The ID and the username of the comment author"
      } do |c|
        c.author&.slice("id", "username", "avatar_url")
      end
      expose :destroyable, documentation: {
        desc:   "Boolean that tells if the current user can destroy or not the comment",
        hidden: true
      }, if: { type: :internal } do |c, options|
        can_destroy_comment?(c, options[:current_user])
      end
    end

    # Teams & members

    class Teams < Grape::Entity
      include ::API::Helpers

      expose :id, documentation: { type: Integer, desc: "Team ID" }
      expose :name, documentation: { type: String, desc: "Team name" }
      expose :created_at, :updated_at, documentation: { type: DateTime }
      expose :description, documentation: {
        type: String,
        desc: "The description of the team"
      }
      expose :description_md, documentation: {
        type:   String,
        desc:   "The description of the team parsed by markdown",
        hidden: true
      }, if: { type: :internal } do |t|
        markdown(t.description)
      end
      expose :hidden, :updated_at, documentation: {
        type: "Boolean",
        desc: "Whether the team is visible to the final user or not"
      }
      expose :role, documentation: {
        type:   String,
        desc:   "The role this of the current user within this team",
        hidden: true
      }, if: { type: :internal } do |team, options|
        role_within_team(options[:current_user], team)
      end
      expose :updatable, documentation: {
        desc:   "Boolean that tells if the current user can destroy the team",
        hidden: true
      }, if: { type: :internal } do |team, options|
        can_manage_team?(team, options[:current_user])
      end
      expose :destroyable, documentation: {
        desc:   "Boolean that tells if the current user can destroy the team",
        hidden: true
      }, if: { type: :internal } do |team, options|
        can_destroy_team?(team, options[:current_user])
      end
      expose :users_count, documentation: {
        type:   Integer,
        desc:   "The number of enabled users that belong to this team",
        hidden: true
      }, if: { type: :internal } do |t|
        t.users.enabled.count
      end
      expose :namespaces_count, documentation: {
        type:   Integer,
        desc:   "The number of namespaces that belong to this team",
        hidden: true
      }, if: { type: :internal } do |t|
        t.namespaces.count
      end
    end

    class TeamMembers < Grape::Entity
      expose :id, documentation: { type: Integer, desc: "Team member ID" }
      expose :team_id, documentation: { type: Integer, desc: "Team member team ID" }
      expose :user_id, documentation: { type: Integer, desc: "Team member user ID" }
      expose :created_at, :updated_at, documentation: { type: DateTime }
      expose :role, documentation: {
        type: String,
        desc: "The role this of the team meber with in the team"
      }
      expose :display_name, documentation: {
        type: String,
        desc: "The team member's display name"
      } do |t|
        t.user.display_username
      end
      expose :admin, documentation: {
        type:   String,
        desc:   "Tells if the team member is an admin or not",
        hidden: true
      }, if: { type: :internal } do |t|
        t.user.admin?
      end
      expose :current, documentation: {
        type:   String,
        desc:   "Tells if it's the current session user",
        hidden: true
      }, if: { type: :internal } do |t, options|
        user = options[:current_user]

        t.user.id == user.id
      end
    end

    # Namespaces

    class Namespaces < Grape::Entity
      include ::API::Helpers

      expose :id, documentation: { type: Integer, desc: "Namespace ID" }
      expose :clean_name, as: :name, documentation: { type: String, desc: "Namespace name" }
      expose :created_at, :updated_at, documentation: { type: DateTime }
      expose :description, documentation: {
        type: String,
        desc: "The description of the namespace"
      }
      expose :description_md, documentation: {
        type:   String,
        desc:   "The description of the namespace parsed by markdown",
        hidden: true
      }, if: { type: :internal } do |n|
        markdown(n.description)
      end
      expose :team, documentation: {
        desc: "The ID and the name of the team containing this namespace"
      } do |namespace|
        namespace.team&.slice("id", "name", "hidden")
      end
      expose :repositories_count, documentation: {
        type:   Integer,
        desc:   "The number of repositories that belong to this namespace",
        hidden: true
      }, if: { type: :internal } do |n|
        n.repositories.count
      end
      expose :webhooks_count, documentation: {
        type:   Integer,
        desc:   "The number of webooks that belong to this namespace",
        hidden: true
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
      # rubocop:disable Style/SymbolProc
      expose :orphan, documentation: {
        type:   "Boolean",
        desc:   "Whether this is an orphan namespace or not",
        hidden: true
      }, if: { type: :internal } do |namespace|
        namespace.orphan?
      end
      # rubocop:enable Style/SymbolProc
      expose :updatable, documentation: {
        desc:   "Boolean that tells if the current user can manage the namespace",
        hidden: true
      }, if: { type: :internal } do |namespace, options|
        can_manage_namespace?(namespace, options[:current_user])
      end
      expose :destroyable, documentation: {
        desc:   "Boolean that tells if the current user can destroy the namespace",
        hidden: true
      }, if: { type: :internal } do |namespace, options|
        can_destroy_namespace?(namespace, options[:current_user])
      end
      expose :permissions, documentation: {
        desc:   "Different permissions for the current user",
        hidden: true
      }, if: { type: :internal } do |namespace, options|
        user = options[:current_user]
        {
          role:       role(namespace, user),
          pull:       can_pull?(namespace, user),
          push:       can_push?(namespace, user),
          webhooks:   user.admin? || role(namespace, user).present?,
          visibility: can_change_visibility?(namespace, user)
        }
      end
    end

    class Webhooks < Grape::Entity
      include ::API::Helpers

      expose :id, documentation: { type: Integer, desc: "Webhook ID" }
      expose :name, documentation: { type: String, desc: "Webhook name" }
      expose :enabled, documentation: { type: "Boolean", desc: "Webhook name" }
      expose :namespace_id, documentation: { type: Integer, desc: "Webhook namespace ID" }
      expose :created_at, :updated_at, documentation: { type: DateTime }
      expose :username, documentation: {
        type: String,
        desc: "Username for the request if authentication is needed"
      }
      expose :password, documentation: {
        type: String,
        desc: "Password for the request if authentication needed"
      }
      expose :url, documentation: { type: String, desc: "Webhook URL" }
      expose :request_method, documentation: {
        type: String,
        desc: "Webhook request method type"
      }
      expose :content_type, documentation: {
        type: String,
        desc: "Webhook request content type"
      }
      expose :updatable, documentation: {
        desc:   "Boolean that tells if the current user can manage the webhook",
        hidden: true
      }, if: { type: :internal } do |webhook, options|
        can_manage_webhook?(webhook, options[:current_user])
      end
      expose :destroyable, documentation: {
        desc:   "Boolean that tells if the current user can destroy the webhook",
        hidden: true
      }, if: { type: :internal } do |webhook, options|
        can_destroy_webhook?(webhook, options[:current_user])
      end
    end

    class WebhookHeaders < Grape::Entity
      expose :id, documentation: { type: Integer, desc: "Webhook header ID" }
      expose :name, documentation: { type: String, desc: "Webhook header name" }
      expose :value, documentation: { type: String, desc: "Webhook header value" }
      expose :webhook_id, documentation: { type: Integer, desc: "Webhook header webhook ID" }
      expose :created_at, :updated_at, documentation: { type: DateTime }
    end

    class WebhookDeliveries < Grape::Entity
      expose :id, documentation: { type: Integer, desc: "Webhook delivery ID" }
      expose :uuid, documentation: { type: String, desc: "Webhook delivery UUID" }
      expose :webhook_id, documentation: { type: Integer, desc: "Webhook delivery webhook ID" }
      expose :created_at, :updated_at, documentation: { type: DateTime }
      expose :status, documentation: { type: Integer, desc: "Webhook delivery HTTP status" }
      expose :request_body, documentation: {
        type: String,
        desc: "Webhook delivery request body value"
      }
      expose :request_header, documentation: {
        type: String,
        desc: "Webhook delivery request header value"
      }
      expose :response_body, documentation: {
        type: String,
        desc: "Webhook delivery response body value"
      }
      expose :response_header, documentation: {
        type: String,
        desc: "Webhook delivery response header value"
      }
    end

    class Version < Grape::Entity
      expose :"api-versions", documentation: {
        type: Array[String],
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
