Rails.application.routes.draw do
  get "/healthcheck.txt", to: "pages#healthcheck"

  get "/pages/:page", to: "pages#show"
  root to: 'candidates/home#index'

  get '/privacy_policy', to: 'pages#privacy_policy'
  get '/cookies_policy', to: 'pages#cookies_policy'

  if Rails.application.config.x.phase_two.enabled
    namespace :schools do
      resource :dashboard, only: :show

      namespace :on_boarding do
        resource :candidate_requirement, only: %i(new create)
        resource :fees, only: %i(new create)
        resource :administration_fee, only: %i(new create)
        resource :dbs_fee, only: %i(new create)
        resource :other_fee, only: %i(new create)
        resource :phases_list, only: %i(new create)
        resource :key_stage_list, only: %i(new create)
        resource :secondary_subjects, only: %i(new create)
        resource :college_subjects, only: %i(new create)
        resource :specialisms, only: %i(new)
      end
    end
  end

  namespace :candidates do
    root to: 'home#index'
    get "splash", to: "home#splash"

    # email confirmation link
    get 'confirm/:uuid', to: 'registrations/placement_requests#create', as: :confirm

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
      end
    end
  end
  resolve('Candidates::SchoolSearch') { %i{candidates schools} }
end
