# frozen_string_literal: true

resource :dashboard, only: [:index]
resources :search, only: [:index]
resources :explore, only: [:index]
resources :errors, only: [:show]
resources :help, only: [:index]
