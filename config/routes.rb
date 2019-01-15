Rails.application.routes.draw do
  get "/pages/:page", to: "pages#show"

  namespace :candidate do
    root to: 'home#index'

    resources :schools, only: [:index, :show] do
      get 'apply', to: 'placement_requests#new'
      post 'apply', to: 'placement_requests#create'
    end
  end
end
