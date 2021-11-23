Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get '/healthcheck.txt', to: 'healthchecks#show', as: :healthcheck
  get '/healthcheck', to: 'healthchecks#show', as: :healthcheck_json
  get '/deployment.txt', to: 'healthchecks#deployment', as: :deployment
  get '/deployment', to: 'healthchecks#deployment', as: :deployment_json
  get '/healthchecks/api.txt', to: 'healthchecks#api_health', as: :api_health
  get '/whitelist', to: 'healthchecks#urn_whitelist', as: :urn_whitelist

  get "/404", to: "errors#not_found", via: :all
  get "/422", to: "errors#unprocessable_entity", via: :all
  get "/500", to: "errors#internal_server_error", via: :all
  get "/429", to: "errors#too_many_requests", via: :all

  if Rails.application.config.x.maintenance_mode
    match '*path', to: 'pages#maintenance', via: :all
    root to: 'pages#maintenance'
  else
    root to: 'candidates/home#index'
  end

  get "/candidates/what_to_expect", to: 'candidates/home#what_to_expect'

  flipper_app = Flipper::UI.app(Flipper.instance) do |builder|
    builder.use Rack::Auth::Basic do |_, password|
      expected_password = Rails.application.config.x.flipper_password
      correct_password = expected_password.present? && password == expected_password

      Rails.env.development? || correct_password
    end
  end
  mount flipper_app, at: "/flipper"

  get "/pages/:page", to: "pages#show"

  get '/privacy_policy', to: 'pages#privacy_policy'
  get '/accessibility_statement', to: 'pages#accessibility_statement'
  get '/cookies_policy', to: 'pages#cookies_policy'
  get '/schools_privacy_policy', to: 'pages#schools_privacy_policy'
  get '/schools/request_organisation', to: 'pages#schools_request_organisation'
  resources :service_updates, only: %i[index show]
  get '/service_update', to: 'service_updates#index'
  get '/help_and_support_access_needs', to: 'pages#help_and_support_access_needs'
  get '/dfe_signin_help', to: 'pages#dfe_signin_help'
  get '/robots', to: 'pages#robots', constraints: ->(req) { req.format == :text }
  get '/sitemap', to: 'pages#sitemap', constraints: ->(req) { req.format == :xml }

  resource :cookie_preference, only: %i[show edit update]

  get '/auth/callback', to: 'schools/sessions#create'

  if Rails.env.servertest? || Rails.env.test?
    get '/auth/insecure_callback', to: 'schools/insecure_sessions#create', as: :insecure_auth_callback
  end

  resource :schools, only: :show
  namespace :schools do
    resource :session, only: %i[show] do
      get :logout
    end
    resource :switch, only: %i[new show], controller: 'switch'

    resource :change_school, only: %i[show create], as: 'change', path: 'change', controller: 'change_schools'

    resource :dashboard, only: :show
    resource :contact_us, only: :show, controller: 'contact_us'
    resource :toggle_enabled, only: %i[edit update], as: 'enabled', controller: 'toggle_enabled'

    resource :organisation_access_request, only: :show

    resources :placement_requests do
      resource :cancellation, only: %i[show new create edit update], controller: 'placement_requests/cancellations' do
        resource :notification_delivery, only: %i[show create], controller: 'placement_requests/cancellations/notification_deliveries'
      end
      namespace :acceptance do
        resource :confirm_booking,
          only: %i[new],
          controller: '/schools/placement_requests/acceptance/confirm_booking'
        resource :make_changes,
          only: %i[new create],
          controller: '/schools/placement_requests/acceptance/make_changes'
        resource :preview_confirmation_email,
          only: %i[edit update],
          controller: '/schools/placement_requests/acceptance/preview_confirmation_email'
        resource :email_sent,
          only: %i[show],
          controller: '/schools/placement_requests/acceptance/email_sent'
      end
      resources :past_attendances,
        only: %i[index],
        controller: 'placement_requests/past_attendance'
      put "/schools/placement_requests/place_under_consideration", to: "/schools/placement_requests/under_consideration#place_under_consideration"
    end
    resources :archived_placement_requests, only: %i[index]
    resources :withdrawn_requests, only: %i[index show]
    resources :rejected_requests, only: %i[index show]
    resources :confirmed_bookings, path: 'bookings', as: 'bookings', only: %i[index show] do
      resource :cancellation, only: %i[show new create edit update], controller: 'confirmed_bookings/cancellations' do
        resource :notification_delivery, only: %i[show create], controller: 'confirmed_bookings/cancellations/notification_deliveries'
      end
      resource :date, only: %i[edit update show], controller: 'confirmed_bookings/date'
    end
    resource :confirm_attendance, only: %i[show update], controller: 'confirm_attendance'
    resources :attendances, only: %i[index]
    resources :previous_bookings, only: %i[index show]
    resource :csv_export, only: %i[show create]

    resource :availability_preference, only: %i[edit update]
    resource :availability_info, only: %i[edit update], controller: 'availability_info'
    resources :placement_dates do
      if Feature.instance.active? :subject_specific_dates
        resource :configuration, only: %i[new create], controller: 'placement_dates/configurations'
        resource :subject_selection, only: %i[new create], controller: 'placement_dates/subject_selections'
      end
    end

    namespace :errors do
      resource :not_registered, controller: :not_registered, only: :show
      resource :no_school, controller: :no_school, only: :show
      resource :auth_failed, controller: :auth_failed, only: :show
      resource :insufficient_privileges, controller: :insufficient_privileges, only: :show
      resource :inaccessible_school, controller: :insufficient_privileges, only: :show
    end

    namespace :on_boarding do
      resource :dbs_requirement, only: %i[new create edit update]
      resource :candidate_requirements_choice, only: %i[new create edit update]
      resource :candidate_requirements_selection, only: %i[new create edit update]
      resource :fees, only: %i[new create edit update]
      resource :administration_fee, only: %i[new create]
      resource :dbs_fee, only: %i[new create]
      resource :other_fee, only: %i[new create]
      resource :phases_list, only: %i[new create edit update]
      resource :key_stage_list, only: %i[new create edit update]
      resource :subjects, only: %i[new create edit update]
      resource :description, only: %i[new create edit update]
      resource :candidate_experience_detail, only: %i[new create edit update]
      resource :access_needs_support, only: %i[new create edit update]
      resource :access_needs_detail, only: %i[new create edit update]
      resource :disability_confident, only: %i[new create edit update]
      resource :access_needs_policy, only: %i[new create edit update]
      resource :experience_outline, only: %i[new create edit update]
      resource :admin_contact, only: %i[new create edit update]
      resource :profile, only: :show
      resource :preview, only: :show
      resource :confirmation, only: %i[create show]
    end

    resources :feedbacks, only: %i[new create show]
  end

  namespace :candidates do
    root to: 'home#index'
    get "splash", to: "home#splash"

    # email confirmation link
    get 'confirm/:uuid', to: 'registrations/placement_requests#create', as: :confirm

    resources :school_searches, only: %i[new]

    get 'verify/:school_id/:token/:uuid', to: 'registrations/sign_ins#update', as: :registration_verify
    put 'verify/:school_id', to: 'registrations/sign_ins#update', as: :registration_verify_code

    resources :schools, only: %i[index show] do
      namespace :registrations do
        resource :personal_information, only: %i[new create edit update]
        resource :sign_in, only: %i[show create]
        resource :contact_information, only: %i[new create edit update]
        resource :education, only: %i[new create edit update]
        resource :teaching_preference, only: %i[new create edit update]
        resource :placement_preference, only: %i[new create edit update]
        resource :background_check, only: %i[new create edit update]
        resource :subject_and_date_information, only: %i[new create edit update]
        resource :application_preview, only: %i[show]
        resource :confirmation_email, only: %i[show create]
        resource :resend_confirmation_email, only: %i[create]
        resource :placement_request, only: %i[show create]
      end
    end

    get 'cancel/:placement_request_token', to: 'placement_requests/cancellations#new', as: :cancel
    resources :placement_requests, only: [], param: :token do
      resource :cancellation, only: %i[new create show], controller: 'placement_requests/cancellations'
    end

    if Rails.application.config.x.phase >= 5
      get 'signin', to: 'sessions#new'
      post 'signin', to: 'sessions#create'
      put 'signin', to: 'sessions#update', as: :signin_code

      resource :dashboard, only: :show
    end

    resources :feedbacks, only: %i[new create show]
  end
  resolve('Candidates::SchoolSearch') { %i[candidates schools] }

  if Rails.application.config.x.delayed_job_admin_enabled
    match "/admin/delayed_job" => DelayedJobWeb, anchor: false, via: %i[get post]
  end
end
