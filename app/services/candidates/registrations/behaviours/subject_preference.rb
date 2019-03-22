module Candidates
  module Registrations
    module Behaviours
      module SubjectPreference
        extend ActiveSupport::Concern

        OPTIONS_CONFIG = YAML.load_file "#{Rails.root}/config/candidate_form_options.yml"
        NOT_APPLYING_FOR_DEGREE = "I don't have a degree and am not studying for one".freeze
        DEGREE_STAGE_REQUIRING_EXPLANATION = 'Other'.freeze
        NO_DEGREE_SUBJECT = 'Not applicable'.freeze

        included do
          validates :urn, presence: true
          validates :degree_stage, presence: true
          validates :degree_stage, inclusion: { in: :available_degree_stages }, if: -> { degree_stage.present? }
          validates :degree_stage_explaination, presence: true, if: :degree_stage_explaination_required?
          validates :degree_subject, presence: true
          validates :degree_subject, inclusion: { in: :available_degree_subjects }, if: -> { degree_subject.present? }
          validates :degree_subject, inclusion: [NO_DEGREE_SUBJECT], if: -> { degree_stage.present? && !degree_stage_requires_subject? }
          validates :degree_subject, exclusion: [NO_DEGREE_SUBJECT], if: -> { degree_stage.present? && degree_stage_requires_subject? }
          validates :teaching_stage, presence: true
          validates :teaching_stage, inclusion: { in: :available_teaching_stages }, if: -> { teaching_stage.present? }
          validates :subject_first_choice, presence: true
          validates :subject_first_choice, inclusion: { in: :available_subject_choices }, if: -> { subject_first_choice.present? }
          validates :subject_second_choice, presence: true
          validates :subject_second_choice, inclusion: { in: :second_subject_choices }, if: -> { subject_second_choice.present? }
        end

        def school
          @school ||= Candidates::School.find urn
        end

        def school_name
          school.name
        end

        def available_subject_choices
          @available_subject_choices ||= Candidates::School.subjects.map(&:last)
        end

        def second_subject_choices
          ["I don't have a second subject"] +
            available_subject_choices
        end

        def available_degree_stages
          OPTIONS_CONFIG.fetch 'DEGREE_STAGES'
        end

        def available_degree_subjects
          OPTIONS_CONFIG.fetch 'DEGREE_SUBJECTS'
        end

        def available_teaching_stages
          OPTIONS_CONFIG.fetch 'TEACHING_STAGES'
        end

        def requires_explanation_for_degree_stage?(some_degree_stage)
          some_degree_stage == DEGREE_STAGE_REQUIRING_EXPLANATION
        end

        def requires_subject_for_degree_stage?(some_degree_stage)
          some_degree_stage != NOT_APPLYING_FOR_DEGREE
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
end
