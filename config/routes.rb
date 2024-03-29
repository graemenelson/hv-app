Rails.application.routes.draw do

  root 'pages#landing'

  # only #connect and #callback are exposed for
  # the instagram resource
  resource :instagram, only: [], controller: :instagram do
    member do
      get :connect
    end
  end
  get '/auth/instagram/callback', to: 'instagram#callback'

  resources :signups do
    member do
      get :information
      put :update_information
      get :subscription
      put :update_subscription
    end
  end
  resource :payment, only: [:show, :update]
  resource :dashboard, only: [:show] do
    member do
      get :build
    end
  end

  resources :reports, only: [], module: 'reports' do
    resource :order, only: [:show, :update]
    resource :archive, only: [:update]
  end

end
