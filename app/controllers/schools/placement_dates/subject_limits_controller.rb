module Schools
  module PlacementDates
    class SubjectLimitsController < BaseController
      before_action :set_placement_date

      def new
        @subject_limit = SubjectLimitForm.new_from_date @placement_date
      end

      def create
        @placement_date.placement_date_subjects.includes(:bookings_subject).all

        @subject_limit = SubjectLimitForm.new_from_date @placement_date
        @subject_limit.assign_attributes form_params

        if @subject_limit.save @placement_date
          redirect_to schools_placement_dates_path
        else
          render 'new'
        end
      end

    private

      def set_placement_date
        @placement_date = \
          current_school.
            bookings_placement_dates.
            includes(:subjects).
            find(params[:placement_date_id])
      end

      def form_key
        SubjectLimitForm.model_name.param_key
      end

      def form_attrs
        @placement_date.subject_ids.map do |id|
          :"max_bookings_count_for_subject_#{id}"
        end
      end

      def form_params
        params.require(form_key).permit(*form_attrs)
      end
    end
  end
end
