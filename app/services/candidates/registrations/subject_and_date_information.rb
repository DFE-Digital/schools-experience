module Candidates
  module Registrations
    class SubjectAndDateInformation < RegistrationStep
      include Behaviours::SubjectAndDateInformation

      attr_accessor :school

      attribute :availability
      attribute :bookings_placement_date_id, :integer
      attribute :bookings_placement_dates_subject_id, :integer

      def placement_date
        @placement_date ||= Bookings::PlacementDate.find(bookings_placement_date_id)
      end

      def placement_date_subject
        @placement_date_subject ||= Bookings::PlacementDateSubject.find(bookings_placement_dates_subject_id)
      end
    end
  end
end
