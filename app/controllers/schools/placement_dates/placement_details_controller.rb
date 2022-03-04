module Schools
  module PlacementDates
    class PlacementDetailsController < BaseController
      include Wizard

      before_action :set_placement_date

      def new
        @placement_detail = PlacementDetail.new_from_date @placement_date
      end

      def create
        @placement_detail = PlacementDetail.new placement_details_params
        if @placement_detail.save @placement_date
          unless placement_details_params.key?(:supports_subjects)
            @placement_date.assign_attributes(supports_subjects: school_supports_subjects?)
            @placement_date.save
          end

          next_step @placement_date, :placement_detail
        else
          render :new
        end
      end

    private

      def school_supports_subjects?
        @current_school.has_secondary_phase?
      end

      def set_placement_date
        @placement_date = \
          current_school.bookings_placement_dates.find params[:placement_date_id]
      end

      def placement_details_params
        params.require(:schools_placement_dates_placement_detail).permit \
          :start_availability_offset, :end_availability_offset, :duration, :virtual, :supports_subjects, :school_has_primary_and_secondary_phases
      end
    end
  end
end
