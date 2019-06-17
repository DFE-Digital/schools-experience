module Candidates
  module Registrations
    class SignInsController < RegistrationsController
      def index
        # FIXME need to retrieve email address and show it
        @resend_link = candidates_school_registrations_sign_ins_path
      end

      def create
        # FIXME TO BE IMPLEMENTED
      end

      def update
        @candidate = Candidates::Session.signin!(params[:id])

        if @candidate
          redirect_to new_candidates_school_registrations_contact_information_path
        else
          @resend_link = candidates_school_registrations_sign_ins_path
        end
      end
    end
  end
end
