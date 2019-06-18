module Candidates
  module Registrations
    class SignInsController < RegistrationsController
      def index
        @email_address = current_registration.personal_information.email
        @resend_link = candidates_school_registrations_sign_ins_path
      end

      def create
        # FIXME SHOULD CREATE A RESEND TOKEN
      end

      def update
        candidate = Candidates::Session.signin!(params[:id])

        if candidate
          self.current_candidate = candidate
          redirect_to new_candidates_school_registrations_contact_information_path
        else
          @resend_link = candidates_school_registrations_sign_ins_path
        end
      end
    end
  end
end
