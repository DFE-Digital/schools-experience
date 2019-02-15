module Candidates
  module Registrations
    class SubjectPreference < RegistrationStep
      include Behaviours::SubjectPreference

      attribute :urn, :string
      attribute :degree_stage, :string
      attribute :degree_stage_explaination, :string
      attribute :degree_subject, :string
      attribute :teaching_stage, :string
      attribute :subject_first_choice, :string
      attribute :subject_second_choice, :string
    end
  end
end
