Rails.application.routes.draw do
  get "/healthcheck.txt", to: "pages#healthcheck"

  get "/pages/:page", to: "pages#show"
  root to: 'candidates/home#index'

  get '/privacy_policy', to: 'pages#privacy_policy'
  get '/cookies_policy', to: 'pages#cookies_policy'

  if Rails.application.config.x.phase_two.enabled
    get '/auth/callback', to: 'schools/sessions#create'

    if Rails.env.servertest? || Rails.env.test?
      get '/auth/insecure_callback', to: 'schools/insecure_sessions#create', as: :insecure_auth_callback
    end

    namespace :schools do
      resource :session, only: %i(show destroy)
      resource :dashboard, only: :show

      resources :placement_requests do
        resource :accept, only: [:show, :create], controller: 'placement_requests/accept'
        resource :reject, only: [:show, :create], controller: 'placement_requests/reject'
        collection do
          resources :upcoming, only: :index, controller: 'placement_requests/upcoming', as: 'upcoming_requests'
        end
      end

      namespace :errors do
        resource :not_registered, controller: :not_registered, only: :show
        resource :no_school, controller: :no_school, only: :show
      end

      namespace :on_boarding do
        resource :candidate_requirement, only: %i(new create edit update)
        resource :fees, only: %i(new create edit update)
        resource :administration_fee, only: %i(new create)
        resource :dbs_fee, only: %i(new create)
        resource :other_fee, only: %i(new create)
        resource :phases_list, only: %i(new create)
        resource :key_stage_list, only: %i(new create)
        resource :secondary_subjects, only: %i(new create)
        resource :college_subjects, only: %i(new create)
        resource :specialism, only: %i(new create)
        resource :candidate_experience_detail, only: %i(new create)
        resource :availability_description, only: %i(new create)
        resource :experience_outline, only: %i(new create)
        resource :admin_contact, only: %i(new create)
        resource :profile, only: :show
      end
    end
  end

  namespace :candidates do
    root to: 'home#index'
    get "splash", to: "home#splash"

    # email confirmation link
    get 'confirm/:uuid', to: 'registrations/placement_requests#create', as: :confirm

    resources :school_searches, only: %i{new}

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
