module Schools
  module OnBoarding
    class CandidateRequirementsSelection < Step
      attribute :on_teacher_training_course, :boolean
      attribute :has_degree, :boolean
      attribute :working_towards_degree, :boolean
      attribute :live_locally, :boolean
      attribute :maximum_distance_from_school, :integer
      attribute :other, :boolean
      attribute :other_details, :string

      validates :on_teacher_training_course, inclusion: [true, false]
      validates :has_degree, inclusion: [true, false]
      validates :working_towards_degree, inclusion: [true, false]
      validates :live_locally, inclusion: [true, false]
      validates :other, inclusion: [true, false]
      validates :maximum_distance_from_school, presence: true, if: :live_locally
      validates :maximum_distance_from_school, numericality: { greater_than: 0 }, if: :maximum_distance_from_school
      validates :maximum_distance_from_school, absence: true, unless: :live_locally
      validates :other_details, presence: true, if: :other
      validates :other_details, absence: true, unless: :other

      def self.compose(
        on_teacher_training_course,
        has_degree,
        working_towards_degree,
        live_locally,
        maximum_distance_from_school,
        other,
        other_details
      )
        new \
          on_teacher_training_course: on_teacher_training_course,
          has_degree: has_degree,
          working_towards_degree: working_towards_degree,
          live_locally: live_locally,
          maximum_distance_from_school: maximum_distance_from_school,
          other: other,
          other_details: other_details
      end

      def valid?(*args)
        ux_fix
        super
      end

    private

      def ux_fix
        self.maximum_distance_from_school = nil unless live_locally
        self.other_details = nil unless other
      end
    end
  end
end
