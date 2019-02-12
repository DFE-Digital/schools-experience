module Candidates
  module Registrations
    class BackgroundChecksController < RegistrationsController
      def new
        @background_check = BackgroundCheck.new
      end

      def create
        @background_check = BackgroundCheck.new background_check_params
        if @background_check.valid?
          persist @background_check
          redirect_to candidates_school_registrations_application_preview_path
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
          persist @background_check
          redirect_to candidates_school_registrations_application_preview_path
        else
          render :edit
        end
      end

    private

      def background_check_params
        params.require(:candidates_registrations_background_check).permit \
          :has_dbs_check
      end
    end
  end
end
