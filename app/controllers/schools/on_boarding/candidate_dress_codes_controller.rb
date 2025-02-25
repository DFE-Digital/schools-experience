module Schools
  module OnBoarding
    class CandidateDressCodesController < OnBoardingsController
      def new
        @candidate_dress_code = CandidateDressCode.new
      end

      def create
        @candidate_dress_code = CandidateDressCode.new \
          candidate_dress_code_params

        if @candidate_dress_code.valid?
          current_school_profile.update! \
            candidate_dress_code: @candidate_dress_code,
            candidate_dress_code_step_completed: true

          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

      def edit
        @candidate_dress_code = duplicate_if_frozen(current_school_profile.candidate_dress_code)
      end

      def update
        @candidate_dress_code = CandidateDressCode.new \
          candidate_dress_code_params

        if @candidate_dress_code.valid?
          current_school_profile.update! \
            candidate_dress_code: @candidate_dress_code

          continue(current_school_profile)
        else
          render :edit
        end
      end

    private

      def candidate_dress_code_params
        params.require(:schools_on_boarding_candidate_dress_code).permit(
          :other_dress_requirements_detail,
          selected_requirements: []
        )
      end
    end
  end
end
