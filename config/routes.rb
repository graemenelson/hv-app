Rails.application.routes.draw do

  root 'pages#landing'

  # only #connect and #callback are exposed for
  # the instagram resource
  resource :instagram, only: [], controller: :instagram do
    member do
      get 'connect'
    end
  end
  get '/auth/instagram/callback', to: 'instagram#callback'

  resources :registrations, only: [:show, :update]
  resource :payment, only: [:show, :update]
  resource :dashboard, only: [:show] do
    member do
      get 'build'
    end
  end

end
