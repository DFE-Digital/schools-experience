Rails.application.routes.draw do
  get "/pages/:page", to: "pages#show"
  root to: 'pages#home'

  namespace :candidates do
    root to: 'home#index'

    resources :schools, only: %i(index show) do
      get 'request_placement', to: 'placement_requests#new'
      post 'request_placement', to: 'placement_requests#create'
    end

    namespace :registrations do
      resource :placement_preference, only: %i(new create)
      resource :account_check, only: %i(new create)
      resource :address, only: %i(new create)
      resource :subject_preference, only: %i(new create)
      resource :background_check, only: %i(new create)
      resource :placement_request, only: %i(show)
    end
  end
end
