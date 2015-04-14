Rails.application.routes.draw do

  root 'application#index'

  namespace :v2, module: 'api/v2', defaults: { format: :json } do
    resource :token, only: [ :show ]
  end

end
