module Candidates
  module Registrations
    class SubjectAndDateInformation < RegistrationStep
      include Behaviours::SubjectAndDateInformation

      attr_accessor :school

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
    end
  end
end
