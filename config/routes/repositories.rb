# frozen_string_literal: true

resources :repositories, only: %i[index show destroy] do
  post :toggle_star, on: :member
  resources :comments, only: %i[create destroy]
end

resources :tags, only: %i[show destroy]
