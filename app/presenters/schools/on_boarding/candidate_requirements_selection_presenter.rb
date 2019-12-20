module Schools
  module OnBoarding
    class CandidateRequirementsSelectionPresenter
      include ActionView::Helpers

      # Initalized with a hash of attributes rather than a profile so it can be
      # shared between Bookings::ProfileAttributesConvertor and
      # Schools::OnBoarding::SchoolProfilePresenter
      def initialize(attributes)
        @attributes = ActiveSupport::HashWithIndifferentAccess.new attributes
      end

      def to_s
        reqs = requirements

        reqs.empty? ? 'None' : reqs.join("\n")
      end

      def requirements
        output = []

        if on_teacher_training_course?
          output << "Must be applying to or have applied to our, or a partner school's, teacher training course"
        end

        if not_on_another_training_course?
          output << "Must not have been accepted onto another teacher training course"
        end

        if has_or_working_towards_degree?
          output << "Must have a degree"
        end

        if live_locally?
          distance = maximum_distance_from_school
          miles = 'mile'.pluralize distance
          output << "They must live within #{distance} #{miles} of the school"
        end

        if provide_photo_identification?
          output << "Photo identification: #{photo_identification_details}"
        end

        if other?
          output << other_details
        end

        output
      end

    private

      def on_teacher_training_course?
        @attributes.fetch \
          :candidate_requirements_selection_on_teacher_training_course
      end

      def not_on_another_training_course?
        @attributes.fetch \
          :candidate_requirements_selection_not_on_another_training_course
      end

      def has_or_working_towards_degree?
        @attributes.fetch \
          :candidate_requirements_selection_has_or_working_towards_degree
      end

      def live_locally?
        @attributes.fetch :candidate_requirements_selection_live_locally
      end

      def maximum_distance_from_school
        @attributes.fetch \
          :candidate_requirements_selection_maximum_distance_from_school
      end

      def provide_photo_identification?
        @attributes.fetch \
          :candidate_requirements_selection_provide_photo_identification
      end

      def photo_identification_details
        @attributes.fetch \
          :candidate_requirements_selection_photo_identification_details
      end

      def other?
        @attributes.fetch :candidate_requirements_selection_other
      end

      def other_details
        @attributes.fetch :candidate_requirements_selection_other_details
      end
    end
  end
end
