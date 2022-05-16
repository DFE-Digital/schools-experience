module Schools
  module OnBoarding
    class CandidateRequirementsSelection < Step
      attribute :selected_requirements, default: []
      attribute :maximum_distance_from_school, :integer
      attribute :photo_identification_details, :string
      attribute :other_details, :string

      validates :maximum_distance_from_school, presence: true, if: :live_locally?
      validates :maximum_distance_from_school, numericality: { greater_than: 0 }, if: :maximum_distance_from_school
      validates :maximum_distance_from_school, absence: true, unless: :live_locally?
      validates :photo_identification_details, presence: true, if: :provide_photo_identification?
      validates :other_details, presence: true, if: :other?
      validates :other_details, absence: true, unless: :other?
      validate :candidate_requirements_or_none_selected

      def self.compose(
        on_teacher_training_course,
        not_on_another_training_course,
        has_or_working_towards_degree,
        live_locally,
        maximum_distance_from_school,
        provide_photo_identification,
        photo_identification_details,
        other,
        other_details
      )
        selected_requirements = []

        selected_requirements << "on_teacher_training_course" if on_teacher_training_course
        selected_requirements << "not_on_another_training_course" if not_on_another_training_course
        selected_requirements << "has_or_working_towards_degree" if has_or_working_towards_degree
        selected_requirements << "live_locally" if live_locally
        selected_requirements << "provide_photo_identification" if provide_photo_identification
        selected_requirements << "other" if other

        # Comparing explicitly to false because a nil attribute shouldn't infer "none".
        if [
          on_teacher_training_course,
          not_on_another_training_course,
          has_or_working_towards_degree,
          live_locally,
          provide_photo_identification,
          other
        ].all?(false)
          selected_requirements << "none"
        end

        new(
          selected_requirements: selected_requirements,
          maximum_distance_from_school: maximum_distance_from_school,
          photo_identification_details: photo_identification_details,
          other_details: other_details,
        )
      end

      def on_teacher_training_course?
        "on_teacher_training_course".in?(selected_requirements)
      end

      def not_on_another_training_course?
        "not_on_another_training_course".in?(selected_requirements)
      end

      def has_or_working_towards_degree?
        "has_or_working_towards_degree".in?(selected_requirements)
      end

      def live_locally?
        "live_locally".in?(selected_requirements)
      end

      def provide_photo_identification?
        "provide_photo_identification".in?(selected_requirements)
      end

      def other?
        "other".in?(selected_requirements)
      end

      def none?
        "none".in?(selected_requirements)
      end

      def valid?(*args)
        ux_fix
        super
      end

    private

      def candidate_requirements_or_none_selected
        # selected_requirements will always contain an empty string from the form body
        requirements = selected_requirements.reject(&:empty?)
        no_options_selected = requirements.empty?
        requirements_and_none_selected = none? && requirements.count > 1

        if no_options_selected || requirements_and_none_selected
          errors.add(:selected_requirements, :no_requirements_selected)
        end
      end

      def ux_fix
        self.maximum_distance_from_school = nil unless live_locally?
        self.photo_identification_details = nil unless provide_photo_identification?
        self.other_details = nil unless other?
      end
    end
  end
end
