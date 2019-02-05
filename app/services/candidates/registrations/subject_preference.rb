module Candidates
  module Registrations
    class SubjectPreference
      include ActiveModel::Model
      include ActiveModel::Attributes

      OPTIONS_CONFIG = YAML.load_file "#{Rails.root}/config/candidate_form_options.yml"
      NOT_APPLYING_FOR_DEGREE = "I don't have a degree and am not studying for one".freeze
      DEGREE_STAGE_REQUIRING_EXPLINATIONN = 'Other'.freeze

      def self.degree_subjects
        OPTIONS_CONFIG.fetch 'DEGREE_SUBJECTS'
      end

      def self.degree_stages
        OPTIONS_CONFIG.fetch 'DEGREE_STAGES'
      end

      def self.subject_choices
        # has same options as degree_subjects in alpha
        OPTIONS_CONFIG.fetch 'DEGREE_SUBJECTS'
      end

      def self.teaching_stages
        OPTIONS_CONFIG.fetch 'TEACHING_STAGES'
      end

      attribute :degree_stage, :string
      attribute :degree_stage_explaination, :string
      attribute :degree_subject, :string
      attribute :teaching_stage, :string
      attribute :subject_first_choice, :string
      attribute :subject_second_choice, :string

      validates :degree_stage, presence: true
      validates :degree_stage, inclusion: degree_stages, if: -> { degree_stage.present? }
      validates :degree_stage_explaination, presence: true, if: :degree_stage_explaination_required?
      validates :degree_subject, presence: true
      validates :degree_subject, inclusion: degree_subjects, if: -> { degree_subject.present? }
      validates :degree_subject, inclusion: ['Not applicable'], if: -> { degree_stage.present? && !applying_for_degree? }
      validates :degree_subject, exclusion: ['Not applicable'], if: -> { degree_stage.present? && applying_for_degree? }
      validates :teaching_stage, presence: true
      validates :teaching_stage, inclusion: teaching_stages, if: -> { teaching_stage.present? }
      validates :subject_first_choice, presence: true
      validates :subject_first_choice, inclusion: subject_choices, if: -> { subject_first_choice.present? }
      validates :subject_second_choice, presence: true
      validates :subject_second_choice, inclusion: subject_choices, if: -> { subject_second_choice.present? }

    private

      def applying_for_degree?
        degree_stage != NOT_APPLYING_FOR_DEGREE
      end

      def degree_stage_explaination_required?
        degree_stage == DEGREE_STAGE_REQUIRING_EXPLINATIONN
      end
    end
  end
end
