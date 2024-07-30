module Candidates
  module Registrations
    module Behaviours
      module Education
        extend ActiveSupport::Concern

        NO_DEGREE_SUBJECT = 'Not applicable'.freeze
        OPTIONS_CONFIG = YAML.load_file Rails.root.join('config', 'candidate_form_options.yml')
        DEGREE_STAGE_REQUIRING_EXPLANATION = 'Other'.freeze
        NOT_APPLYING_FOR_DEGREE = "I don't have a degree and am not studying for one".freeze

        included do
          validates :degree_stage, presence: true
          validates :degree_stage, inclusion: { in: :available_degree_stages }, if: -> { degree_stage.present? }
          validates :degree_stage_explaination, presence: true, if: :degree_stage_explaination_required?

          # if DEGREE_SUBJECT_AUTOCOMPLETE_ENABLED=true (degree_subject_autocomplete?)
          # + if javascript is disabled (nojs?), then
          validates :degree_subject_nojs, presence: true, if: -> { degree_subject_autocomplete? && nojs? && degree_stage_requires_subject? }
          validates :degree_subject_nojs, absence: true,  if: -> { degree_subject_autocomplete? && nojs? && !degree_stage_requires_subject? }

          # # + else if javascript is enabled (js?), then
          validates :degree_subject, presence: true,  if: -> { degree_subject_autocomplete? && js? && degree_stage_requires_subject? }
          validates :degree_subject, absence: true,   if: -> { degree_subject_autocomplete? && js? && !degree_stage_requires_subject? }

          # if DEGREE_SUBJECT_AUTOCOMPLETE_ENABLED=false (degree_subject_simple?)
          validates :degree_subject, presence: true,                                if: -> { degree_subject_simple? && degree_stage_requires_subject? }
          validates :degree_subject, inclusion: { in: :available_degree_subjects }, if: -> { degree_subject_simple? && degree_stage_requires_subject? }
          validates :degree_subject, inclusion: [NO_DEGREE_SUBJECT],                if: -> { degree_subject_simple? && degree_stage_requires_n_a_subject? }
          validates :degree_subject, exclusion: [NO_DEGREE_SUBJECT],                if: -> { degree_subject_simple? && degree_stage_requires_subject_in_subjects_list? }
        end

        def js?
          !nojs?
        end

        def nojs?
          ActiveModel::Type::Boolean.new.cast(nojs) if defined?(nojs)
        end

        def available_degree_stages
          OPTIONS_CONFIG.fetch 'DEGREE_STAGES'
        end

        def available_degree_subjects
          @available_degree_subjects ||=
            if degree_subject_autocomplete?
              DfE::ReferenceData::Degrees::SUBJECTS.all
            else
              OPTIONS_CONFIG.fetch 'DEGREE_SUBJECTS'
            end
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

        def degree_subject_autocomplete?
          @degree_subject_autocomplete ||= ActiveModel::Type::Boolean.new.cast(ENV.fetch("DEGREE_SUBJECT_AUTOCOMPLETE_ENABLED", false))
        end

        def degree_subject_simple?
          !degree_subject_autocomplete?
        end

      private

        def degree_stage_requires_subject?
          requires_subject_for_degree_stage? degree_stage
        end

        def degree_stage_explaination_required?
          requires_explanation_for_degree_stage? degree_stage
        end

        def degree_stage_requires_subject_in_subjects_list?
          degree_subject.present? &&
            degree_stage.present? &&
            degree_stage_requires_subject?
        end

        def degree_stage_requires_n_a_subject?
          degree_subject.present? &&
            degree_stage.present? &&
            !degree_stage_requires_subject?
        end
      end
    end
  end
end
