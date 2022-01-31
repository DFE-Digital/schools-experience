module Candidates
  module Registrations
    class PlacementPreference < RegistrationStep
      include Behaviours::PlacementPreference

      attribute :objectives, :string

      # TODO: SE-1877 remove this
      attr_accessor :bookings_placement_date_id
    end
  end
end
