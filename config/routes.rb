Rails.application.routes.draw do
  get "/pages/:page", to: "pages#show"
  root to: 'pages#home'

  namespace :candidate do
    root to: 'home#index'

    resources :schools, only: %i(index show) do
      get 'request_placement', to: 'placement_requests#new'
      post 'request_placement', to: 'placement_requests#create'
    end

    namespace :registrations do
      resources :placements, only: %i(new create)
      resources :account_checks, only: %i(new create)
      resources :personal_details, only: %i(new create)
      resources :account_infos, only: %i(new create)
      resources :dbs_checks, only: %i(new create)
      resource  :placement_request, only: %i(show)
    end
  end
end
