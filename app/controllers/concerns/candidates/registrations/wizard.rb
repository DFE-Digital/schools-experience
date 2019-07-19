module Candidates
  module Registrations
    module Wizard
      extend ActiveSupport::Concern

      included do
        before_action :ensure_step_permitted!
      end

    private

      def ensure_step_permitted!
        redirect_to next_step_path unless current_path_permitted?
      end

      def current_path
        controller_path.split('/').last.singularize.to_sym
      end

      def current_path_permitted?
        return true if registration_state.completed?

        if current_path_is_a_wizard_step?
          wizard_step_permitted?
        else
          signing_in?
        end
      end

      def current_path_is_a_wizard_step?
        registration_state.steps.include? current_path
      end

      def wizard_step_permitted?
        registration_state.step_completed?(current_path) || \
          registration_state.next_step == current_path
      end

      def signing_in?
        current_path == :sign_in && \
          registration_state.step_completed?(:personal_information)
      end

      def registration_root
        "/candidates/schools/#{current_registration.urn}/registrations"
      end

      def next_step_path
        if registration_state.next_step == :COMPLETED
          [registration_root, 'application_preview'].join('/')
        else
          [registration_root, registration_state.next_step, 'new'].join('/')
        end
      end

      def registration_state
        Registrations::RegistrationState.new current_registration
      end
    end
  end
end
