module Candidates
  module Registrations
    class PlacementPreference < RegistrationStep
      include Behaviours::PlacementPreference

      attribute :bookings_placement_date_id, :integer
      attribute :availability, :string
      attribute :objectives, :string
    end
  end
end
