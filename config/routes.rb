Rails.application.routes.draw do
  get "/pages/:page", to: "pages#show"
  root to: 'candidates/home#index'

  namespace :candidates do
    root to: 'home#index'

    resources :schools, only: %i{index show} do
      namespace :registrations do
        resource :placement_preference, only: %i(new create edit)
        resource :account_check, only: %i(new create edit update)
        resource :address, only: %i(new create edit)
        resource :subject_preference, only: %i(new create edit)
        resource :background_check, only: %i(new create edit update)
        resource :application_preview, only: %i(show)
        resource :placement_request, only: %i(show create)
      end
    end
  end
  resolve('Candidates::SchoolSearch') { %i{candidates schools} }
end
