# frozen_string_literal: true

resources :namespaces, only: %i[index show] do
  resources :webhooks do
    resources :headers, only: %i[create destroy], controller: :webhook_headers
    resources :deliveries, only: [:update], controller: :webhook_deliveries
    member do
      put "toggle_enabled"
    end
  end
end

get "namespaces/typeahead/:query" => "namespaces#typeahead",
    as: "namespaces_typeahead", :defaults => { format: "json" }
