# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do

	def draw(routes_module)
    instance_eval(File.read(Rails.root.join("config/routes/#{routes_module}.rb")))
	end
  resources :errors, only: [:show]
	draw :teams
  resources :help, only: [:index]

  resources :team_users, only: %i[create destroy update]
	draw :namespaces
	draw :repositories
  resources :tags, only: %i[show destroy]
  resources :application_tokens, only: %i[create destroy]
	draw :user
  resource :dashboard, only: [:index]
  resources :search, only: [:index]
  resources :explore, only: [:index]
	draw :v2
  mount API::RootAPI => "/"
  mount GrapeSwaggerRails::Engine, at: "/documentation" unless Rails.env.production?

  get "users/oauth", to: "auth/omniauth_registrations#new"
  post "users/oauth", to: "auth/omniauth_registrations#create"

	draw :admin

  # Error pages.
  %w[401 404 422 500].each do |code|
    get "/#{code}", to: "errors#show", status: code
  end
end
# rubocop:enable Metrics/BlockLength
