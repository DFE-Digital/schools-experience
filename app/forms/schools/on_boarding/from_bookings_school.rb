# Maps attributes from a bookings school to attributes for a
# schools/on_boarding/step
module Schools
  module OnBoarding
    class FromBookingsSchool
      def initialize(bookings_school)
        @bookings_school = bookings_school
      end

      def [](model_name)
        send "attributes_for_#{model_name}"
      end

    private

      def attributes_for_availability_description
        { description: @bookings_school.availability_info }
      end

      def attributes_for_availability_preference
        fixed = @bookings_school.availability_info.present? ? false : nil
        { fixed: fixed }
      end

      def attributes_for_experience_outline
        {
          candidate_experience: @bookings_school.placement_info,
          provides_teacher_training: @bookings_school.teacher_training_provider.presence,
          teacher_training_details: @bookings_school.teacher_training_info,
          teacher_training_url: @bookings_school.teacher_training_website
        }
      end

      def attributes_for_key_stage_list
        stages = @bookings_school.primary_key_stage_info.to_s.split(', ')
        {
          early_years: stages.include?('Early years foundation stage (EYFS)'),
          key_stage_1: stages.include?('Key stage 1'),
          key_stage_2: stages.include?('Key stage 2')
        }
      end

      def attributes_for_phases_list
        {
          primary: @bookings_school.primary_key_stage_info.present?
        }
      end

      def attributes_for_subject_list
        { subject_ids: @bookings_school.subject_ids }
      end
    end
  end
end
