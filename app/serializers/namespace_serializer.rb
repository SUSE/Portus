class NamespaceSerializer < ApplicationSerializer
  cache key: "namespace"

  attributes :id, :clean_name, :global, :visibility, :created_at

  link :self do
    href namespace_path(object)
  end

  meta do
    {
      can_change_visibility: scope.can_change_visibility?(object)
    }
  end

  # relationships

  # webhooks
  has_many :webhooks do
    include_data false

    if scope.can_view_webhooks?(object)
      link :related do
        href namespace_webhooks_path(object)
      end
    end

    meta do
      {
        count: object.webhooks.count
      }
    end
  end

  # repositories
  has_many :repositories do
    include_data false

    meta do
      {
        count: object.repositories.count
      }
    end
  end
end
