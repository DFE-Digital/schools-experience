module Schools
  module PlacementDates
    class SubjectSpecificsController < BaseController
      before_action :set_placement_date

      def new
        @subject_specific = SubjectSpecificForm.new_from_date @placement_date
      end

      def create
        @subject_specific = SubjectSpecificForm.new form_params
        @subject_specific.supports_subjects = @placement_date.supports_subjects

        if @subject_specific.save @placement_date
          redirect_to next_step
        else
          render :new
        end
      end

    private

      def next_step
        if @subject_specific.subject_specific?
          new_schools_placement_date_subject_selection_path @placement_date
        elsif @placement_date.capped?
          new_schools_placement_date_date_limit_path @placement_date
        else
          schools_placement_dates_path
        end
      end

      def set_placement_date
        @placement_date = \
          current_school.bookings_placement_dates.find params[:placement_date_id]
      end

      # FIXME - Remove - transitional only
      def form_key
        if params.has_key?(SubjectSpecificForm.model_name.param_key)
          SubjectSpecificForm.model_name.param_key
        else
          :schools_placement_dates_configuration_form
        end
      end

      def form_params
        params.fetch(form_key, {}).permit(
          :available_for_all_subjects
        )
      end
    end
  end
end
