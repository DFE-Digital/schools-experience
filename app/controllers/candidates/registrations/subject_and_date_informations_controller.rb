module Candidates
  module Registrations
    class SubjectAndDateInformationsController < RegistrationsController
      before_action :set_school

      def new
        @subject_and_date_information = SubjectAndDateInformation.new(attributes_from_session)
      end

      def create
        @subject_and_date_information = SubjectAndDateInformation.new(attributes_from_session)

        @subject_and_date_information.assign_attributes(extract_subject_and_date_params)

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
        @subject_and_date_information.assign_attributes(extract_subject_and_date_params)

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

      def subject_and_date_params
        params.require(:candidates_registrations_subject_and_date_information).permit(:subject_and_date_ids)
      end

      def extract_subject_and_date_params
        bookings_placement_date_id, bookings_placement_dates_subject_id = \
          *subject_and_date_params.dig('subject_and_date_ids').split('_')

        bookings_subject_id = Bookings::PlacementDateSubject.find_by(id: bookings_placement_dates_subject_id)&.bookings_subject_id

        {
          bookings_placement_date_id: bookings_placement_date_id,
          bookings_subject_id: bookings_subject_id
        }
      end

      def attributes_from_session
        current_registration.subject_and_date_information_attributes.merge(urn: @school.urn)
      end
    end
  end
end
