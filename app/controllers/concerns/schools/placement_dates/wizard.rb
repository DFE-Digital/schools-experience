module Schools
  module PlacementDates
    module Wizard
      extend ActiveSupport::Concern

      STEPS = %i[
        placement_date
        placement_detail
        configuration
        subject_selection
      ].freeze

    private

      def next_step(placement_date, current_step = :placement_date)
        next_step = find_next_step(current_step)
        if next_step == :COMPLETED
          placement_date.publish
          auto_enable_school
          redirect_to schools_placement_dates_path
        else
          redirect_to next_step_path(placement_date, next_step)
        end
      end

      def find_next_step(current_step)
        STEPS.drop(STEPS.index(current_step) + 1).detect(&method(:required?)) || :COMPLETED
      end

      def next_step_path(placement_date, next_step)
        public_send "new_schools_placement_date_#{next_step}_path", placement_date
      end

      def required?(step)
        send "#{step}_required?"
      end

      def placement_detail_required?
        true
      end

      def configuration_required?
        @placement_date.supports_subjects?
      end

      def subject_selection_required?
        @placement_date.subject_specific?
      end
    end
  end
end