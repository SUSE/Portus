# frozen_string_literal: true

resources :errors, only: [:show]
resource :dashboard, only: [:index]
resources :search, only: [:index]
resources :explore, only: [:index]
resources :help, only: [:index]
