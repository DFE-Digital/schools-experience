module Candidates
  module Registrations
    class ContactInformationsController < RegistrationsController
      def new
        @contact_information = ContactInformation.new
      end

      def create
        @contact_information = ContactInformation.new contact_information_params
        if @contact_information.valid?
          persist @contact_information
          redirect_to new_candidates_school_registrations_subject_preference_path
        else
          render :new
        end
      end

      def edit
        @contact_information = current_registration.contact_information
      end

      def update
        @contact_information = current_registration.contact_information
        @contact_information.assign_attributes contact_information_params

        if @contact_information.valid?
          persist @contact_information
          redirect_to candidates_school_registrations_application_preview_path
        else
          render :edit
        end
      end

      private

      def contact_information_params
        params.require(:candidates_registrations_contact_information).permit \
          :full_name,
          :email,
          :building,
          :street,
          :town_or_city,
          :county,
          :postcode,
          :phone
      end
    end
  end
end

