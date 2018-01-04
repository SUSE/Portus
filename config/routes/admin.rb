namespace :admin do
	resources :activities, only: [:index]
	resources :dashboard, only: [:index]
	resources :registries, except: %i[show destroy]
	resources :namespaces, only: [:index]
	resources :teams, only: [:index]
 	resources :users do
  	put "toggle_admin", on: :member
  end
end
