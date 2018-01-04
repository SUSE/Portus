devise_for :users, controllers: { registrations:      "auth/registrations",
                                  sessions:           "auth/sessions",
                                  passwords:          "passwords",
                                  omniauth_callbacks: "auth/omniauth_callbacks" }

authenticated :user do
	root "dashboard#index", as: :authenticated_root
end

devise_scope :user do
	root to: "auth/sessions#new"
	put "toggle_enabled/:id", to: "auth/registrations#toggle_enabled", as: :toggle_enabled
end
