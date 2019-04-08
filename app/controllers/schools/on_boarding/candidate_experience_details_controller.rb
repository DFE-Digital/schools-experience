module Schools
  module OnBoarding
    class CandidateExperienceDetailsController < OnBoardingsController
      def new
        @candidate_experience_detail = CandidateExperienceDetail.new
      end

      def create
        @candidate_experience_detail = CandidateExperienceDetail.new \
          candidate_experience_detail_params

        if @candidate_experience_detail.valid?
          current_school_profile.update! \
            candidate_experience_detail: @candidate_experience_detail

          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

    private

      def candidate_experience_detail_params
        params.require(:schools_on_boarding_candidate_experience_detail).permit \
          :business_dress,
          :cover_up_tattoos,
          :remove_piercings,
          :smart_casual,
          :other_dress_requirements,
          :other_dress_requirements_detail,
          :parking_provided,
          :parking_details,
          :nearby_parking_details,
          :disabled_facilities,
          :disabled_facilities_details,
          :start_time,
          :end_time,
          :times_flexible
      end
    end
  end
end
