module Candidates
  module Registrations
    class Education < RegistrationStep
      NO_DEGREE_SUBJECT = 'Not applicable'.freeze
      OPTIONS_CONFIG = YAML.load_file "#{Rails.root}/config/candidate_form_options.yml"
      DEGREE_STAGE_REQUIRING_EXPLANATION = 'Other'.freeze
      NOT_APPLYING_FOR_DEGREE = "I don't have a degree and am not studying for one".freeze

      attribute :degree_stage, :string
      attribute :degree_stage_explaination, :string
      attribute :degree_subject, :string

      validates :degree_stage, presence: true
      validates :degree_stage, inclusion: { in: :available_degree_stages }, if: -> { degree_stage.present? }
      validates :degree_stage_explaination, presence: true, if: :degree_stage_explaination_required?
      validates :degree_subject, presence: true
      validates :degree_subject, inclusion: { in: :available_degree_subjects }, if: -> { degree_subject.present? }
      validates :degree_subject, inclusion: [NO_DEGREE_SUBJECT], if: -> { degree_stage.present? && !degree_stage_requires_subject? }
      validates :degree_subject, exclusion: [NO_DEGREE_SUBJECT], if: -> { degree_stage.present? && degree_stage_requires_subject? }

      def available_degree_stages
        OPTIONS_CONFIG.fetch 'DEGREE_STAGES'
      end

      def available_degree_subjects
        OPTIONS_CONFIG.fetch 'DEGREE_SUBJECTS'
      end

      def requires_subject_for_degree_stage?(some_degree_stage)
        some_degree_stage != NOT_APPLYING_FOR_DEGREE
      end

      def requires_explanation_for_degree_stage?(some_degree_stage)
        some_degree_stage == DEGREE_STAGE_REQUIRING_EXPLANATION
      end

      def no_degree_subject
        NO_DEGREE_SUBJECT
      end

    private

      def degree_stage_requires_subject?
        requires_subject_for_degree_stage? degree_stage
      end

      def degree_stage_explaination_required?
        requires_explanation_for_degree_stage? degree_stage
      end
    end
  end
end
