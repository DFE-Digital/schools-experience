module Candidates
  module Registrations
    class SubjectAndDateInformation < RegistrationStep
      include Behaviours::SubjectAndDateInformation

      PlacementDateOption = Struct.new(:placement_date_id, :placement_date_subject_id, :name, :duration) do
        def id
          [placement_date_id, placement_date_subject_id].compact.join('_')
        end

        def name_with_duration
          "#{name} (#{duration} #{'day'.pluralize(duration)})"
        end
      end

      attribute :availability
      attribute :bookings_placement_date_id, :integer
      attribute :bookings_placement_dates_subject_id, :integer

      validates :bookings_placement_date_id, presence: true

      def placement_date
        @placement_date ||= Bookings::PlacementDate.find_by(id: bookings_placement_date_id)
      end

      def placement_date_subject
        @placement_date_subject ||= Bookings::PlacementDateSubject.find_by(id: bookings_placement_dates_subject_id)
      end

      def subject_and_date_ids
        [bookings_placement_date_id, bookings_placement_dates_subject_id].join('_')
      end

      def primary_placement_dates
        school
          .bookings_placement_dates
          .in_date_order
          .not_supporting_subjects
      end

      def secondary_placement_dates_grouped_by_date
        school
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
    end
  end
end
