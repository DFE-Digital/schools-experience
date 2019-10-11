module Candidates
  module Registrations
    class SubjectAndDateInformationsController < RegistrationsController
      before_action :set_school, :set_placement_dates

      def new
        @subject_and_date_information = SubjectAndDateInformation.new(attributes_from_session)
      end

      def create
        @subject_and_date_information = SubjectAndDateInformation.new(attributes_from_session)

        # FIXME set the date and subject here
        @subject_and_date_information.assign_attributes(subject_and_date_params)

        if @subject_and_date_information.valid?
          persist @subject_and_date_information
          redirect_to new_candidates_school_registrations_personal_information_path(current_urn)
        else
          render :new
        end
      end

      def edit
        @subject_and_date_information = SubjectAndDateInformation.new(attributes_from_session)
      end

      def update
        @subject_and_date_information = SubjectAndDateInformation.new(attributes_from_session)
        @subject_and_date_information.assign_attributes(subject_and_date_params)

        if @subject_and_date_information.valid?
          persist @subject_and_date_information
          redirect_to candidates_school_registrations_application_preview_path
        else
          render :edit
        end
      end

    private

      def set_school
        @school = current_registration.school
      end

      def set_placement_dates
        if @school.availability_preference_fixed?
          @placement_dates = @school
            .bookings_placement_dates
            .published
            .available
        end
      end

      def subject_and_date_params
        params.require(:candidates_registrations_subject_and_date_information).permit(
          :bookings_placement_date_id,
          :subject_id
        )
      end

      def attributes_from_session
        current_registration.subject_and_date_information_attributes
      end
    end
  end
end
