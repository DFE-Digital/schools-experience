module Candidates
  module Registrations
    class BackgroundCheck < RegistrationStep
      attribute :has_dbs_check, :boolean

      validates :has_dbs_check, inclusion: [true, false]
    end
  end
end
