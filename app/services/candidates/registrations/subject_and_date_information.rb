module Candidates
  module Registrations
    class SubjectAndDateInformation < RegistrationStep
      include Behaviours::SubjectAndDateInformation

      attribute :availability
      attribute :bookings_placement_date_id, :integer
      attribute :bookings_subject_id, :integer

      validates :bookings_subject_id, presence: true, if: :for_subject_specific_date?

      def placement_date
        @placement_date ||= Bookings::PlacementDate.find_by(id: bookings_placement_date_id)
      end

      def placement_date_subject
        @placement_date_subject ||= Bookings::PlacementDateSubject.find_by(
          bookings_placement_date_id: bookings_placement_date_id,
          bookings_subject_id: bookings_subject_id
        )
      end

      def bookings_subject
        @bookings_subject ||= Bookings::Subject.find_by(id: bookings_subject_id)
      end

      def date_and_subject_ids
        placement_date_subject&.date_and_subject_id || placement_date&.id
      end

      def date_and_subject_ids=(pair)
        self.bookings_placement_date_id, self.bookings_subject_id = pair.split('_')
      end

      def primary_placement_dates
        school
          .bookings_placement_dates
          .primary
          .in_date_order
          .map do |placement_date|
            PlacementDateOption.new(
              placement_date.id,
              placement_date.date.to_formatted_s(:govuk),
              placement_date.duration,
              placement_date.date
            )
          end
      end

      def secondary_placement_dates_grouped_by_date
        school
          .bookings_placement_dates
          .secondary
          .in_date_order
          .eager_load(placement_date_subjects: :bookings_subject)
          .map(&PlacementDateOption.method(:for_secondary_date))
          .flatten
          .group_by(&:date)
      end
    end
  end
end
