module Candidates
  module Registrations
    PlacementDateOption = Struct.new(:placement_date_id, :placement_date_subject_id, :name) do
      def id
        [placement_date_id, placement_date_subject_id].compact.join('_')
      end
    end

    class SubjectAndDateInformationsController < RegistrationsController
      before_action :set_school, :set_placement_dates

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

      def set_placement_dates
        @placement_dates_grouped_by_date = @school
          .bookings_placement_dates
          .eager_load(placement_date_subjects: :bookings_subject)
          .published
          .available
          .each
          .with_object({}) do |pd, h|
            if h.has_key?(pd.date)
              h[pd.date].concat(placement_date_options(pd))
            else
              h[pd.date] = Array.wrap(placement_date_options(pd))
            end
          end
      end

      def placement_date_options(placement_date)
        if placement_date.placement_date_subjects.any?
          placement_date.placement_date_subjects.map do |placement_date_subject|
            PlacementDateOption.new(placement_date.id, placement_date_subject.id, placement_date_subject.bookings_subject.name)
          end
        else
          Array.wrap(PlacementDateOption.new(placement_date.id, nil, 'All subjects'))
        end
      end

      def subject_and_date_params
        params
          .require(:candidates_registrations_subject_and_date_information)
          .permit(:subject_and_date_ids)
      end

      def extract_subject_and_date_params
        bookings_placement_date_id, bookings_placement_dates_subject_id = \
          *subject_and_date_params.dig('subject_and_date_ids').split('_')

        {
          bookings_placement_date_id: bookings_placement_date_id,
          bookings_placement_dates_subject_id: bookings_placement_dates_subject_id
        }
      end

      def attributes_from_session
        current_registration.subject_and_date_information_attributes
      end
    end
  end
end
