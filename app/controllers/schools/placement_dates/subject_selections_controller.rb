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
          redirect_to schools_placement_dates_path
        else
          render :new
        end
      end

    private

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
