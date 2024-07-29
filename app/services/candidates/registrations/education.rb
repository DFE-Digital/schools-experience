module Candidates
  module Registrations
    class Education < RegistrationStep
      include Behaviours::Education
      attribute :degree_stage, :string
      attribute :degree_stage_explaination, :string
      attribute :degree_subject, :string

      attr_accessor :degree_subject_raw, :degree_subject_nojs, :nojs

      def initialize(*)
        super
        self.degree_subject_nojs = degree_subject
      end
    end
  end
end
