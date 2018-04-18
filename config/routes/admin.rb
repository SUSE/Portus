# frozen_string_literal: true

namespace :admin do
  resources :activities, only: [:index]
  resources :registries, except: %i[show destroy]
  resources :users do
    put "toggle_admin", on: :member
  end
end
