# frozen_string_literal: true

namespace :v2, module: "api/v2", defaults: { format: :json } do
  root to: "ping#ping", as: :ping
  resource :token, only: [:show]
  resource :webhooks, only: [] do
    resources :events, only: [:create]
  end
end
