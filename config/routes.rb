Rails.application.routes.draw do
  resources :errors, only: [:show]
  resources :teams, only: [:index, :show, :create]
  resources :team_users, only: [:create, :destroy, :update]
  resources :namespaces, only: [:create, :index, :show] do
    put "toggle_public", on: :member
  end

  resources :repositories, only: [:index, :show] do
    post :toggle_star, on: :member
  end

  devise_for :users, controllers: { registrations: "auth/registrations",
                                    sessions:      "auth/sessions",
                                    passwords:     "passwords" }
  resource :dashboard, only: [:index]
  resources :search, only: [:index]

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

  namespace :admin do
    resources :activities, only: [:index]
    resources :dashboard, only: [:index]
    resources :registries, only: [:index, :create, :new, :update]
    resources :namespaces, only: [:index]
    resources :teams, only: [:index]
    resources :users, only: [:index] do
      put "toggle_admin", on: :member
    end
  end
  match "(errors)/:status", to: "errors#show", constraints: { status: /\d{3}/ }, via: :all
end
