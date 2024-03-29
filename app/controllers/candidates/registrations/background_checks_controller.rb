module Candidates
  module Registrations
    class BackgroundChecksController < RegistrationsController
      def new
        @background_check = BackgroundCheck.new attributes_from_session
      end

      def create
        @background_check = BackgroundCheck.new background_check_params

        if @background_check.valid?
          if dbs_requirements_met?
            persist @background_check
            redirect_to next_step_path
          else
            render :unmet_requirements
          end
        else
          render :new
        end
      end

      def edit
        @background_check = current_registration.background_check
      end

      def update
        @background_check = current_registration.background_check
        @background_check.assign_attributes background_check_params

        if @background_check.valid?
          if dbs_requirements_met?
            persist @background_check
            redirect_to candidates_school_registrations_application_preview_path
          else
            render :unmet_requirements
          end
        else
          render :edit
        end
      end

    private

      def background_check_params
        params.require(:candidates_registrations_background_check).permit \
          :has_dbs_check
      end

      def attributes_from_session
        current_registration.background_check_attributes.except 'created_at'
      end

      def dbs_requirements_met?
        school = Bookings::School.find_by!(urn: params[:school_id])

        DbsRequirmentsChecker.new(school, @background_check, current_registration).requirements_met?
      end
    end
  end
end
