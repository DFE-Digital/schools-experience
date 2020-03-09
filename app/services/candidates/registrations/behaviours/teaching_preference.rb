module Candidates
  module Registrations
    module Behaviours
      module TeachingPreference
        extend ActiveSupport::Concern

        OPTIONS_CONFIG = YAML.load_file Rails.root.join('config', 'candidate_form_options.yml')

        included do
          validates :teaching_stage, presence: true
          validates :teaching_stage, inclusion: { in: :available_teaching_stages }, if: -> { teaching_stage.present? }
          validates :subject_first_choice, presence: true
          validates :subject_first_choice, inclusion: { in: :available_subject_choices }, if: -> { subject_first_choice.present? }
          validates :subject_second_choice, presence: true
          validates :subject_second_choice, inclusion: { in: :second_subject_choices }, if: -> { subject_second_choice.present? }
        end

        def available_teaching_stages
          OPTIONS_CONFIG.fetch 'TEACHING_STAGES'
        end

        def available_subject_choices
          @available_subject_choices ||= get_available_subject_choices
        end

        def second_subject_choices
          ["I don't have a second subject"] +
            available_subject_choices
        end

      private

        def get_available_subject_choices
          if school.subjects.any?
            school.subjects.pluck :name
          else
            all_available_subject_choices
          end
        end

        def all_available_subject_choices
          Candidates::School.subjects.map(&:last)
        end
      end
    end
  end
end
