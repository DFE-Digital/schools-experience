module Schools
  module OnBoarding
    class CandidateRequirementsSelectionPresenter
      # Initalized with a hash of attributes rather than a profile so it can be
      # shared between Bookings::ProfileAttributesConvertor and
      # Schools::OnBoarding::SchoolProfilePresenter
      def initialize(attributes)
        @attributes = ActiveSupport::HashWithIndifferentAccess.new attributes
      end

      def to_s
        output = []

        if on_teacher_training_course?
          output << "Must be applying to or have been accepted onto our, or a partner school's, teacher training course"
        end

        if has_degree?
          output << "Must have a degree"
        end

        if working_towards_degree?
          output << "Must be working towards a degree"
        end

        if live_locally?
          distance = maximum_distance_from_school
          miles = 'mile'.pluralize distance
          output << "They must live within #{distance} #{miles} from the school"
        end

        if other?
          output << other_details
        end


        if output.empty?
          'None'
        else
          output.join('. ')
        end
      end

    private

      def on_teacher_training_course?
        @attributes.fetch \
          :candidate_requirements_selection_on_teacher_training_course
      end

      def has_degree?
        @attributes.fetch \
          :candidate_requirements_selection_has_degree
      end

      def working_towards_degree?
        @attributes.fetch \
          :candidate_requirements_selection_working_towards_degree
      end

      def live_locally?
        @attributes.fetch :candidate_requirements_selection_live_locally
      end

      def other?
        @attributes.fetch :candidate_requirements_selection_other
      end

      def maximum_distance_from_school
        @attributes.fetch \
          :candidate_requirements_selection_maximum_distance_from_school
      end

      def other_details
        @attributes.fetch :candidate_requirements_selection_other_details
      end
    end
  end
end
