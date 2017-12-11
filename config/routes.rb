# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
# TODO: see https://github.com/SUSE/Portus/issues/1469
Rails.application.routes.draw do
  resources :errors, only: [:show]
  resources :teams, only: %i[index show update] do
    member do
      get "typeahead/:query" => "teams#typeahead", :defaults => { format: "json" }
    end
  end
  get "/teams/typeahead/:query" => "teams#all_with_query", :defaults => { format: "json" }

  resources :help, only: [:index]

  resources :team_users, only: %i[create destroy update]
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

  resources :repositories, only: %i[index show destroy] do
    post :toggle_star, on: :member
    resources :comments, only: %i[create destroy]
  end

  resources :tags, only: %i[show destroy]

  resources :application_tokens, only: %i[create destroy]

  devise_for :users, controllers: { registrations:      "auth/registrations",
                                    sessions:           "auth/sessions",
                                    passwords:          "passwords",
                                    omniauth_callbacks: "auth/omniauth_callbacks" }
  resource :dashboard, only: [:index]
  resources :search, only: [:index]
  resources :explore, only: [:index]

  authenticated :user do
    root "dashboard#index", as: :authenticated_root
  end

  devise_scope :user do
    root to: "auth/sessions#new"
    put "toggle_enabled/:id", to: "auth/registrations#toggle_enabled", as: :toggle_enabled
  end

  namespace :v2, module: "api/v2", defaults: { format: :json } do
    root to: "ping#ping", as: :ping
    resource :token, only: [:show]
    resource :webhooks, only: [] do
      resources :events, only: [:create]
    end
  end

  mount API::RootAPI => "/"
  mount GrapeSwaggerRails::Engine, at: "/documentation" unless Rails.env.production?

  get "users/oauth", to: "auth/omniauth_registrations#new"
  post "users/oauth", to: "auth/omniauth_registrations#create"

  namespace :admin do
    resources :activities, only: [:index]
    resources :dashboard, only: [:index]
    resources :registries, except: %i[show destroy]
    resources :namespaces, only: [:index]
    resources :teams, only: [:index]
    resources :users do
      put "toggle_admin", on: :member
    end
  end

  # Error pages.
  %w[401 404 422 500].each do |code|
    get "/#{code}", to: "errors#show", status: code
  end
end
# rubocop:enable Metrics/BlockLength
