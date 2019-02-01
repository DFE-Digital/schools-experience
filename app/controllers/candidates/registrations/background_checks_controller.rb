module Candidates
  module Registrations
    class BackgroundChecksController < RegistrationsController
      def new
        @background_check = BackgroundCheck.new
      end

      def create
        @background_check = BackgroundCheck.new background_check_params
        if @background_check.valid?
          current_registration[:background_check] = @background_check.attributes
          redirect_to candidates_registrations_placement_request_path
        else
          render :new
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
