module Schools
  module OnBoarding
    class CandidateParkingInformationsController < OnBoardingsController
      def new
        @candidate_parking_information = CandidateParkingInformation.new
      end

      def create
        @candidate_parking_information = CandidateParkingInformation.new \
          candidate_parking_information_params

        if @candidate_parking_information.valid?
          current_school_profile.update! \
            candidate_parking_information: @candidate_parking_information

          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

      def edit
        # NB: we must initialise new models when editing an existing one because
        # we are using the composed_of framework to build the components of
        # SchoolProfile. Otherwise, frozen variable errors will be triggered.
        @candidate_parking_information = CandidateParkingInformation.new(current_school_profile.candidate_parking_information.attributes)
      end

      def update
        @candidate_parking_information = CandidateParkingInformation.new \
          candidate_parking_information_params

        if @candidate_parking_information.valid?
          current_school_profile.update! \
            candidate_parking_information: @candidate_parking_information

          continue(current_school_profile)
        else
          render :edit
        end
      end

    private

      def candidate_parking_information_params
        params.require(:schools_on_boarding_candidate_parking_information).permit \
          :parking_provided,
          :parking_details,
          :nearby_parking_details
      end
    end
  end
end
