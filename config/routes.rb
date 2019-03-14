Rails.application.routes.draw do
  get "/healthcheck.txt", to: "pages#healthcheck"

  get "/pages/:page", to: "pages#show"
  root to: 'candidates/home#index'

  if PHASE_TWO
    namespace :schools do
      resource :dashboard, only: :show
    end
  end

  namespace :candidates do
    root to: 'home#index'
    get "splash", to: "home#splash"

    resources :schools, only: %i{index show} do
      namespace :registrations do
        resource :placement_preference, only: %i(new create edit update)
        resource :contact_information, only: %i(new create edit update)
        resource :subject_preference, only: %i(new create edit update)
        resource :background_check, only: %i(new create edit update)
        resource :application_preview, only: %i(show)
        resource :confirmation_email, only: %i(show create)
        resource :resend_confirmation_email, only: %i(create)
        resource :placement_request, only: %i(show create)
        # email confirmation link
        get 'placement_request/new', to: 'placement_requests#create'
      end
    end
  end
  resolve('Candidates::SchoolSearch') { %i{candidates schools} }
end
