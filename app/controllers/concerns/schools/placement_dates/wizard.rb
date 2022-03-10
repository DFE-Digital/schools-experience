module Schools
  module PlacementDates
    module Wizard
      extend ActiveSupport::Concern

      STEPS = %i[
        placement_date
        recurrences_selection
        review_recurrences
        placement_detail
        configuration
        subject_selection
        publish_dates
      ].freeze

    private

      def next_step(placement_date, current_step = :placement_date)
        next_step = find_next_step(current_step)

        if next_step == :COMPLETED
          placement_date.publish!(recurrences_session[:recurrences])
          auto_enable_school
          redirect_to schools_placement_dates_path
        else
          @placement_date.mark_as_publishable! if next_step == STEPS.last

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

      def recurrences_selection_required?
        @placement_date.recurring?
      end

      def review_recurrences_required?
        recurrences_selection_required?
      end

      def publish_dates_required?
        true
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

      def recurrences_session
        session["date-recurrences-#{@placement_date.id}"] ||= {
          recurrences: []
        }
      end
    end
  end
end
