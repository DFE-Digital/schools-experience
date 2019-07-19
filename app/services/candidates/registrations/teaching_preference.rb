module Candidates
  module Registrations
    class TeachingPreference < RegistrationStep
      include Behaviours::TeachingPreference
      attr_accessor :school

      attribute :teaching_stage, :string
      attribute :subject_first_choice, :string
      attribute :subject_second_choice, :string
    end
  end
end
