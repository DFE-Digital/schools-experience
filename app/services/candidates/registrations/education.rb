module Candidates
  module Registrations
    class Education < RegistrationStep
      include Behaviours::Education
      attribute :degree_stage, :string
      attribute :degree_stage_explaination, :string
      attribute :degree_subject, :string

      attr_accessor :degree_subject_raw
    end
  end
end
