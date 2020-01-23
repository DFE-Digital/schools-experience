module Schools
  module PlacementDates
    class SubjectSelectionsController < BaseController
      before_action :set_placement_date

      def new
        @subject_selection = SubjectSelection.new_from_date @placement_date
      end

      def create
        @subject_selection = SubjectSelection.new subject_selection_params

        if @subject_selection.save @placement_date
          redirect_to next_step
        else
          render :new
        end
      end

    private

      def next_step
        if @placement_date.capped?
          new_schools_placement_date_subject_limit_path @placement_date
        else
          schools_placement_dates_path
        end
      end

      def set_placement_date
        @placement_date = \
          current_school.bookings_placement_dates.find params[:placement_date_id]
      end

      def subject_selection_params
        params.require(:schools_placement_dates_subject_selection).permit \
          :available_for_all_subjects,
          subject_ids: []
      end
    end
  end
end
