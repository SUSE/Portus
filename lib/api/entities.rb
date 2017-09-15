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
      } do |tag|
        sec = ::Portus::Security.new(tag.repository.full_name, tag.name)
        sec.vulnerabilities
      end
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
      expose :stars, documentation: {
        type: Integer,
        desc: "The number of stars for this repository"
      } { |repository| repository.stars.count }
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
    end

    class Namespaces < Grape::Entity
      expose :id, documentation: { type: Integer, desc: "Namespace ID" }
      expose :clean_name, as: :name, documentation: { type: String, desc: "Namespace name" }
      expose :created_at, :updated_at, documentation: { type: DateTime }
      expose :team_id, documentation: {
        type: Integer,
        desc: "The ID of the team containing this namespace"
      }
      expose :repositories_count, documentation: {
        type: Integer,
        desc: "The number of repositories that belong to this namespace"
      } { |n| n.repositories.count }
      expose :webhooks_count, documentation: {
        type: Integer,
        desc: "The number of webooks that belong to this namespace"
      } { |n| n.webhooks.count }
      expose :registry_id, documentation: {
        type: Integer,
        desc: "The ID of the registry containing this namespace"
      }
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
    end
  end
end
