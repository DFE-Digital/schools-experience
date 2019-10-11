module Candidates
  module Registrations
    class PlacementPreference < RegistrationStep
      include Behaviours::PlacementPreference

      attribute :urn, :integer
      attribute :bookings_placement_date_id, :integer
      attribute :availability, :string
      attribute :objectives, :string

      def school
        @school ||= Candidates::School.find(urn)
      end
    end
  end
end
