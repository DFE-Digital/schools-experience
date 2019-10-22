module Candidates
  module Registrations
    class ContactInformationsController < RegistrationsController
      def new
        @contact_information = \
          current_registration.build_contact_information attributes_from_session
      end

      def create
        @contact_information = \
          current_registration.build_contact_information contact_information_params

        if @contact_information.save
          redirect_to next_step_path
        else
          render :new
        end
      end

      def edit
        @contact_information = current_registration.contact_information
      end

      def update
        @contact_information = current_registration.contact_information

        if @contact_information.update contact_information_params
          redirect_to candidates_school_registrations_application_preview_path
        else
          render :edit
        end
      end

    private

      def contact_information_params
        params.require(:candidates_registrations_contact_information).permit \
          :first_name,
          :last_name,
          :email,
          :date_of_birth,
          :building,
          :street,
          :town_or_city,
          :county,
          :postcode,
          :phone
      end

      def attributes_from_session
        current_registration.contact_information_attributes.except 'created_at'
      end
    end
  end
end
