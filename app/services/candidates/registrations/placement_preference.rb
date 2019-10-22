module Candidates
  module Registrations
    class PlacementPreference < RegistrationStep
      include Behaviours::PlacementPreference

      attribute :bookings_placement_date_id, :integer
      attribute :availability, :string
      attribute :objectives, :string

      def placement_date
        @placement_date ||= Bookings::PlacementDate.find(bookings_placement_date_id)
      end
    end
  end
end
