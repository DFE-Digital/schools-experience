module Candidates
  module Registrations
    class PlacementPreference < RegistrationStep
      include Behaviours::PlacementPreference

      attribute :availability, :string
      attribute :objectives, :string

      # delete this at least 24 hours after subject-specific dates
      # has been deployed
      attribute :bookings_placement_date_id, :integer
    end
  end
end
