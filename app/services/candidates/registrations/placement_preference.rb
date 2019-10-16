module Candidates
  module Registrations
    class PlacementPreference < RegistrationStep
      include Behaviours::PlacementPreference

      attribute :availability, :string
      attribute :objectives, :string
    end
  end
end
