Rails.application.routes.draw do
  get "/pages/:page", to: "pages#show"

  namespace :candidate do
    root to: 'home#index'

    resources :schools, only: [:index, :show] do
      get 'request_placement', to: 'placement_requests#new'
      post 'request_placement', to: 'placement_requests#create'
    end
  end
end
