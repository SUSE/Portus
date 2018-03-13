# frozen_string_literal: true

Rails.application.routes.draw do
  %i[root teams namespaces admin registry_api repositories users].each { |f| draw f }

  mount API::RootAPI => "/"
  mount GrapeSwaggerRails::Engine, at: "/documentation" unless Rails.env.production?

  # Error pages.
  %w[401 404 422 500].each do |code|
    get "/#{code}", to: "errors#show", status: code
  end
end
