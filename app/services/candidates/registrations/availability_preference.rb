module Candidates
  module Registrations
    class AvailabilityPreference < RegistrationStep
      include Behaviours::AvailabilityPreference

      attribute :availability, :string
    end
  end
end
