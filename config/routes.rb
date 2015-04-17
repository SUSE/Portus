Rails.application.routes.draw do
  resources :images, only: [ :index, :show ]
  resources :repositories, only: [ :index, :show ]
  devise_for :users, controllers: { registrations: 'auth/registrations', sessions: 'auth/sessions' }
  root 'dashboards#show'

  namespace :v2, module: 'api/v2', defaults: { format: :json } do
    resource :token, only: [ :show ]
    resource :webhooks, only: [] do
      resources :events, only: [ :create ]
    end
  end

  resource :dashboard, only: [ :show ]
end
