Rails.application.routes.draw do
  get "/healthcheck.txt", to: "pages#healthcheck"

  get "/pages/:page", to: "pages#show"
  root to: 'candidates/home#index'

  get '/privacy_policy', to: 'pages#privacy_policy'
  get '/cookies_policy', to: 'pages#cookies_policy'
  get '/schools_privacy_policy', to: 'pages#schools_privacy_policy'
  get '/service_update', to: 'pages#service_update' if Rails.application.config.x.phase >= 4

  get '/auth/callback', to: 'schools/sessions#create'

  if Rails.env.servertest? || Rails.env.test?
    get '/auth/insecure_callback', to: 'schools/insecure_sessions#create', as: :insecure_auth_callback
  end

  resource :schools, only: :show
  namespace :schools do
    resource :session, only: %i(show) do
      get :logout
    end
    resource :switch, only: %i(new), controller: 'switch'
    resource :dashboard, only: :show
    resource :toggle_enabled, only: %i(edit update), as: 'enabled', controller: 'toggle_enabled'

    if Rails.application.config.x.phase >= 4
      resources :placement_requests do
        resource :cancellation, only: %i(show new create edit update), controller: 'placement_requests/cancellations' do
          resource :notification_delivery, only: %i(show create), controller: 'placement_requests/cancellations/notification_deliveries'
        end
        namespace :acceptance do
          resource :confirm_booking,
            only: [:new, :create],
            controller: '/schools/placement_requests/acceptance/confirm_booking'
          resource :add_more_details,
            only: [:new, :create],
            controller: '/schools/placement_requests/acceptance/add_more_details'
          resource :review_and_send_email,
            only: [:new, :create],
            controller: '/schools/placement_requests/acceptance/review_and_send_email'
          resource :preview_confirmation_email,
            only: [:new, :create],
            controller: '/schools/placement_requests/acceptance/preview_confirmation_email'
          resource :email_sent,
            only: [:show],
            controller: '/schools/placement_requests/acceptance/email_sent'
        end
        namespace :acceptance do
          resource :confirm_booking,
            only: [:new, :create],
            controller: '/schools/placement_requests/acceptance/confirm_booking'
          resource :add_more_details,
            only: [:new, :create],
            controller: '/schools/placement_requests/acceptance/add_more_details'
          resource :review_and_send_email,
            only: [:new, :create],
            controller: '/schools/placement_requests/acceptance/review_and_send_email'
          resource :preview_confirmation_email,
            only: [:new, :create],
            controller: '/schools/placement_requests/acceptance/preview_confirmation_email'
          resource :email_sent,
            only: [:show],
            controller: '/schools/placement_requests/acceptance/email_sent'
        end
      end
      resources :confirmed_bookings, path: 'bookings', as: 'bookings', only: %i(index show) do
        resource :cancellation, only: %i(show new create edit update), controller: 'confirmed_bookings/cancellations' do
          resource :notification_delivery, only: %i(show create), controller: 'confirmed_bookings/cancellations/notification_deliveries'
        end
        resource :date, only: %i(edit update show), controller: 'confirmed_bookings/date'
      end
      resource :confirm_attendance, only: %i(show update), controller: 'confirm_attendance'
    end

    resource :availability_preference, only: %i(edit update)
    resource :availability_info, only: %i(edit update), controller: 'availability_info'
    resources :placement_dates

    namespace :errors do
      resource :not_registered, controller: :not_registered, only: :show
      resource :no_school, controller: :no_school, only: :show
      resource :auth_failed, controller: :auth_failed, only: :show
    end

    namespace :on_boarding do
      resource :candidate_requirement, only: %i(new create edit update)
      resource :fees, only: %i(new create edit update)
      resource :administration_fee, only: %i(new create)
      resource :dbs_fee, only: %i(new create)
      resource :other_fee, only: %i(new create)
      resource :phases_list, only: %i(new create edit update)
      resource :key_stage_list, only: %i(new create edit update)
      resource :subjects, only: %i(new create edit update)
      resource :description, only: %i(new create edit update)
      resource :candidate_experience_detail, only: %i(new create edit update)
      resource :experience_outline, only: %i(new create edit update)
      resource :admin_contact, only: %i(new create edit update)
      resource :profile, only: :show
      resource :confirmation, only: %i(create show)
    end

    resources :feedbacks, only: %i(new create show)
  end

  namespace :candidates do
    root to: 'home#index'
    get "splash", to: "home#splash"

    # email confirmation link
    get 'confirm/:uuid', to: 'registrations/placement_requests#create', as: :confirm

    resources :school_searches, only: %i{new}

    if Rails.application.config.x.phase >= 3
      get 'verify/:school_id/:token', to: 'registrations/sign_ins#update', as: :registration_verify
    end

    resources :schools, only: %i{index show} do
      namespace :registrations do
        resource :personal_information, only: %i(new create edit update)
        if Rails.application.config.x.phase >= 3
          resource :sign_in, only: %i(show create)
        end
        resource :contact_information, only: %i(new create edit update)
        resource :education, only: %i(new create edit update)
        resource :teaching_preference, only: %i(new create edit update)
        resource :placement_preference, only: %i(new create edit update)
        resource :background_check, only: %i(new create edit update)
        resource :application_preview, only: %i(show)
        resource :confirmation_email, only: %i(show create)
        resource :resend_confirmation_email, only: %i(create)
        resource :placement_request, only: %i(show create)
      end
    end

    if Rails.application.config.x.phase >= 4
      get 'cancel/:placement_request_token', to: 'placement_requests/cancellations#new', as: :cancel
      resources :placement_requests, only: [], param: :token do
        resource :cancellation, only: %i(new create show), controller: 'placement_requests/cancellations'
      end
    end

    if Rails.application.config.x.phase >= 5
      get 'signin', to: 'sessions#new'
      post 'signin', to: 'sessions#create'
      get 'signin/:authtoken', to: 'sessions#update', as: 'signin_confirmation'

      resource :dashboard, only: :show
    end

    resources :feedbacks, only: %i(new create show)
  end
  resolve('Candidates::SchoolSearch') { %i{candidates schools} }


  if Rails.application.config.x.delayed_job_admin_enabled
    match "/admin/delayed_job" => DelayedJobWeb, :anchor => false, :via => [:get, :post]
  end
end
