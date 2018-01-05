# frozen_string_literal: true

resources :namespaces, only: %i[index show update] do
  put "change_visibility", on: :member
  resources :webhooks do
    resources :headers, only: %i[create destroy], controller: :webhook_headers
    resources :deliveries, only: [:update], controller: :webhook_deliveries
    member do
      put "toggle_enabled"
    end
  end
end

get "namespaces/typeahead/:query" => "namespaces#typeahead", :defaults => { format: "json" }
