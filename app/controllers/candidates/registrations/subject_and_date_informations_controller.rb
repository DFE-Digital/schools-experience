module Candidates
  module Registrations
    class SubjectAndDateInformationsController < RegistrationsController
      before_action :set_school, :set_primary_placement_dates, :set_secondary_placement_dates

      PlacementDateOption = Struct.new(:placement_date_id, :placement_date_subject_id, :name, :duration) do
        def id
          [placement_date_id, placement_date_subject_id].compact.join('_')
        end

        def name_with_duration
          "#{name} (#{duration} #{'day'.pluralize(duration)})"
        end
      end

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

      def set_primary_placement_dates
        @primary_placement_dates = @school
          .bookings_placement_dates
          .in_date_order
          .not_supporting_subjects
      end

      def set_secondary_placement_dates
        @secondary_placement_dates_grouped_by_date =  \
          secondary_placement_dates.each_value { |v| v.sort_by!(&:name) }
      end

      def secondary_placement_dates
        @school
          .bookings_placement_dates
          .in_date_order
          .supporting_subjects
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
            PlacementDateOption.new(placement_date.id, placement_date_subject.id, placement_date_subject.bookings_subject.name, placement_date.duration)
          end
        else
          Array.wrap(PlacementDateOption.new(placement_date.id, nil, 'All subjects', placement_date.duration))
        end
      end

      def subject_and_date_params
        params.require(:candidates_registrations_subject_and_date_information).permit(:subject_and_date_ids).tap do |subject_and_date_info|
          subject_and_date_info.require(:subject_and_date_ids)
        end
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
