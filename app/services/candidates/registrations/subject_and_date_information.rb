module Candidates
  module Registrations
    class SubjectAndDateInformation < RegistrationStep
      include Behaviours::SubjectAndDateInformation

      attr_accessor :school

      attribute :availability
      attribute :bookings_placement_date_id, :integer
      #attribute :subject_id # note this isn't the same as subject_first_choice

      def placement_date
        @placement_date ||= Bookings::PlacementDate.find(bookings_placement_date_id)
      end
    end
  end
end
