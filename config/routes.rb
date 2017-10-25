# == Route Map
#
# [Mailer config] Host:     portus.test.lan
# [Mailer config] Protocol: http://
#                           Prefix Verb     URI Pattern                                                             Controller#Action
#                            error GET      /errors/:id(.:format)                                                   errors#show
#                                  GET      /teams/:id/typeahead/:query(.:format)                                   teams#typeahead {:format=>"json"}
#                            teams GET      /teams(.:format)                                                        teams#index
#                             team GET      /teams/:id(.:format)                                                    teams#show
#                                  PATCH    /teams/:id(.:format)                                                    teams#update
#                                  PUT      /teams/:id(.:format)                                                    teams#update
#                                  GET      /teams/typeahead/:query(.:format)                                       teams#all_with_query {:format=>"json"}
#                       help_index GET      /help(.:format)                                                         help#index
#                       team_users POST     /team_users(.:format)                                                   team_users#create
#                        team_user PATCH    /team_users/:id(.:format)                                               team_users#update
#                                  PUT      /team_users/:id(.:format)                                               team_users#update
#                                  DELETE   /team_users/:id(.:format)                                               team_users#destroy
#      change_visibility_namespace PUT      /namespaces/:id/change_visibility(.:format)                             namespaces#change_visibility
#        namespace_webhook_headers POST     /namespaces/:namespace_id/webhooks/:webhook_id/headers(.:format)        webhook_headers#create
#         namespace_webhook_header DELETE   /namespaces/:namespace_id/webhooks/:webhook_id/headers/:id(.:format)    webhook_headers#destroy
#       namespace_webhook_delivery PATCH    /namespaces/:namespace_id/webhooks/:webhook_id/deliveries/:id(.:format) webhook_deliveries#update
#                                  PUT      /namespaces/:namespace_id/webhooks/:webhook_id/deliveries/:id(.:format) webhook_deliveries#update
# toggle_enabled_namespace_webhook PUT      /namespaces/:namespace_id/webhooks/:id/toggle_enabled(.:format)         webhooks#toggle_enabled
#               namespace_webhooks GET      /namespaces/:namespace_id/webhooks(.:format)                            webhooks#index
#                                  POST     /namespaces/:namespace_id/webhooks(.:format)                            webhooks#create
#            new_namespace_webhook GET      /namespaces/:namespace_id/webhooks/new(.:format)                        webhooks#new
#           edit_namespace_webhook GET      /namespaces/:namespace_id/webhooks/:id/edit(.:format)                   webhooks#edit
#                namespace_webhook GET      /namespaces/:namespace_id/webhooks/:id(.:format)                        webhooks#show
#                                  PATCH    /namespaces/:namespace_id/webhooks/:id(.:format)                        webhooks#update
#                                  PUT      /namespaces/:namespace_id/webhooks/:id(.:format)                        webhooks#update
#                                  DELETE   /namespaces/:namespace_id/webhooks/:id(.:format)                        webhooks#destroy
#                       namespaces GET      /namespaces(.:format)                                                   namespaces#index
#                        namespace GET      /namespaces/:id(.:format)                                               namespaces#show
#                                  PATCH    /namespaces/:id(.:format)                                               namespaces#update
#                                  PUT      /namespaces/:id(.:format)                                               namespaces#update
#                                  GET      /namespaces/typeahead/:query(.:format)                                  namespaces#typeahead {:format=>"json"}
#           toggle_star_repository POST     /repositories/:id/toggle_star(.:format)                                 repositories#toggle_star
#              repository_comments POST     /repositories/:repository_id/comments(.:format)                         comments#create
#               repository_comment DELETE   /repositories/:repository_id/comments/:id(.:format)                     comments#destroy
#                     repositories GET      /repositories(.:format)                                                 repositories#index
#                       repository GET      /repositories/:id(.:format)                                             repositories#show
#                                  DELETE   /repositories/:id(.:format)                                             repositories#destroy
#                              tag GET      /tags/:id(.:format)                                                     tags#show
#                                  DELETE   /tags/:id(.:format)                                                     tags#destroy
#               application_tokens POST     /application_tokens(.:format)                                           application_tokens#create
#                application_token DELETE   /application_tokens/:id(.:format)                                       application_tokens#destroy
#                 new_user_session GET      /users/sign_in(.:format)                                                auth/sessions#new
#                     user_session POST     /users/sign_in(.:format)                                                auth/sessions#create
#             destroy_user_session DELETE   /users/sign_out(.:format)                                               auth/sessions#destroy
#          user_omniauth_authorize GET|POST /users/auth/:provider(.:format)                                         auth/omniauth_callbacks#passthru {:provider=>/google_oauth2|open_id|github|gitlab|bitbucket/}
#           user_omniauth_callback GET|POST /users/auth/:action/callback(.:format)                                  auth/omniauth_callbacks#(?-mix:google_oauth2|open_id|github|gitlab|bitbucket)
#                    user_password POST     /users/password(.:format)                                               passwords#create
#                new_user_password GET      /users/password/new(.:format)                                           passwords#new
#               edit_user_password GET      /users/password/edit(.:format)                                          passwords#edit
#                                  PATCH    /users/password(.:format)                                               passwords#update
#                                  PUT      /users/password(.:format)                                               passwords#update
#         cancel_user_registration GET      /users/cancel(.:format)                                                 auth/registrations#cancel
#                user_registration POST     /users(.:format)                                                        auth/registrations#create
#            new_user_registration GET      /users/sign_up(.:format)                                                auth/registrations#new
#           edit_user_registration GET      /users/edit(.:format)                                                   auth/registrations#edit
#                                  PATCH    /users(.:format)                                                        auth/registrations#update
#                                  PUT      /users(.:format)                                                        auth/registrations#update
#                                  DELETE   /users(.:format)                                                        auth/registrations#destroy
#                     search_index GET      /search(.:format)                                                       search#index
#                    explore_index GET      /explore(.:format)                                                      explore#index
#                            _ping GET      /_ping(.:format)                                                        health#index
#                          _health GET      /_health(.:format)                                                      health#health
#               authenticated_root GET      /                                                                       dashboard#index
#                             root GET      /                                                                       auth/sessions#new
#                   toggle_enabled PUT      /toggle_enabled/:id(.:format)                                           auth/registrations#toggle_enabled
#                          v2_ping GET      /v2(.:format)                                                           api/v2/ping#ping {:format=>:json}
#                         v2_token GET      /v2/token(.:format)                                                     api/v2/tokens#show {:format=>:json}
#               v2_webhooks_events POST     /v2/webhooks/events(.:format)                                           api/v2/events#create {:format=>:json}
#                     api_root_api          /                                                                       API::RootAPI
#              grape_swagger_rails          /api/documentation                                                      GrapeSwaggerRails::Engine
#                      users_oauth GET      /users/oauth(.:format)                                                  auth/omniauth_registrations#new
#                                  POST     /users/oauth(.:format)                                                  auth/omniauth_registrations#create
#                 admin_activities GET      /admin/activities(.:format)                                             admin/activities#index
#            admin_dashboard_index GET      /admin/dashboard(.:format)                                              admin/dashboard#index
#                 admin_registries GET      /admin/registries(.:format)                                             admin/registries#index
#                                  POST     /admin/registries(.:format)                                             admin/registries#create
#               new_admin_registry GET      /admin/registries/new(.:format)                                         admin/registries#new
#              edit_admin_registry GET      /admin/registries/:id/edit(.:format)                                    admin/registries#edit
#                   admin_registry PATCH    /admin/registries/:id(.:format)                                         admin/registries#update
#                                  PUT      /admin/registries/:id(.:format)                                         admin/registries#update
#                 admin_namespaces GET      /admin/namespaces(.:format)                                             admin/namespaces#index
#                      admin_teams GET      /admin/teams(.:format)                                                  admin/teams#index
#          toggle_admin_admin_user PUT      /admin/users/:id/toggle_admin(.:format)                                 admin/users#toggle_admin
#                      admin_users GET      /admin/users(.:format)                                                  admin/users#index
#                                  POST     /admin/users(.:format)                                                  admin/users#create
#                   new_admin_user GET      /admin/users/new(.:format)                                              admin/users#new
#                  edit_admin_user GET      /admin/users/:id/edit(.:format)                                         admin/users#edit
#                       admin_user GET      /admin/users/:id(.:format)                                              admin/users#show
#                                  PATCH    /admin/users/:id(.:format)                                              admin/users#update
#                                  PUT      /admin/users/:id(.:format)                                              admin/users#update
#                                  DELETE   /admin/users/:id(.:format)                                              admin/users#destroy
#                                  GET      /401(.:format)                                                          errors#show {:status=>"401"}
#                                  GET      /404(.:format)                                                          errors#show {:status=>"404"}
#                                  GET      /422(.:format)                                                          errors#show {:status=>"422"}
#                                  GET      /500(.:format)                                                          errors#show {:status=>"500"}
#
# Routes for GrapeSwaggerRails::Engine:
#   root GET  /           grape_swagger_rails/application#index
#

Rails.application.routes.draw do
  resources :errors, only: [:show]
  resources :teams, only: [:index, :show, :update] do
    member do
      get "typeahead/:query" => "teams#typeahead", :defaults => { format: "json" }
    end
  end
  get "/teams/typeahead/:query" => "teams#all_with_query", :defaults => { format: "json" }

  resources :help, only: [:index]

  resources :team_users, only: [:create, :destroy, :update]
  resources :namespaces, only: [:index, :show, :update] do
    put "change_visibility", on: :member
    resources :webhooks do
      resources :headers, only: [:create, :destroy], controller: :webhook_headers
      resources :deliveries, only: [:update], controller: :webhook_deliveries
      member do
        put "toggle_enabled"
      end
    end
  end
  get "namespaces/typeahead/:query" => "namespaces#typeahead", :defaults => { format: "json" }

  resources :repositories, only: [:index, :show, :destroy] do
    post :toggle_star, on: :member
    resources :comments, only: [:create, :destroy]
  end

  resources :tags, only: [:show, :destroy]

  resources :application_tokens, only: [:create, :destroy]

  devise_for :users, controllers: { registrations:      "auth/registrations",
                                    sessions:           "auth/sessions",
                                    passwords:          "passwords",
                                    omniauth_callbacks: "auth/omniauth_callbacks" }
  resource :dashboard, only: [:index]
  resources :search, only: [:index]
  resources :explore, only: [:index]

  # Health check
  get "/_ping", to: "health#index"
  get "/_health", to: "health#health"

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
  mount GrapeSwaggerRails::Engine, at: "/api/documentation" unless Rails.env.production?

  get "users/oauth", to: "auth/omniauth_registrations#new"
  post "users/oauth", to: "auth/omniauth_registrations#create"

  namespace :admin do
    resources :activities, only: [:index]
    resources :dashboard, only: [:index]
    resources :registries, except: [:show, :destroy]
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
