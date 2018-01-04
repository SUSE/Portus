resources :teams, only: %i[index show update] do
	member do
  	get "typeahead/:query" => "teams#typeahead", :defaults => { format: "json" }
  end
end
get "/teams/typeahead/:query" => "teams#all_with_query", :defaults => { format: "json" }
