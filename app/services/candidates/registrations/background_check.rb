module Candidates
  module Registrations
    class BackgroundCheck < RegistrationStep
      include Behaviours::BackgroundCheck
      attribute :has_dbs_check, :boolean
    end
  end
end
