Rails.application.routes.draw do
  resources :teams, only: [ :index, :show, :create ]
  resources :team_users, only: [ :create, :destroy, :update ]
  resources :namespaces, only: [ :create, :index, :show ] do
    put 'toggle_public', on: :member
  end
  resources :repositories, only: [ :index, :show ]
  devise_for :users, controllers: { registrations: 'auth/registrations', sessions: 'auth/sessions' }
  resource :dashboard, only: [ :index ]
  root 'dashboard#index'

  namespace :v2, module: 'api/v2', defaults: { format: :json } do
    root to: 'ping#ping', as: :ping
    resource :token, only: [ :show ]
    resource :webhooks, only: [] do
      resources :events, only: [ :create ]
    end
  end

  namespace :admin do
    resources :dashboard, only: [ :index ]
    resources :registries, only: [ :index, :create, :new ]
    resources :namespaces, only: [ :index ]
    resources :teams, only: [ :index ]
    resources :users, only: [ :index ] do
      put 'toggle_admin', on: :member
    end
  end

end
