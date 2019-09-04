module Schools
  module OnBoarding
    class CandidateRequirementsChoicesController < OnBoardingsController
      def new
        @candidate_requirements_choice = CandidateRequirementsChoice.new
      end

      def create
        @candidate_requirements_choice = \
          CandidateRequirementsChoice.new candidate_requirements_choice_params

        if @candidate_requirements_choice.valid?
          current_school_profile.update! \
            candidate_requirements_choice: @candidate_requirements_choice

          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

      def edit
        @candidate_requirements_choice = \
          current_school_profile.candidate_requirements_choice
      end

      def update
        @candidate_requirements_choice = \
          CandidateRequirementsChoice.new candidate_requirements_choice_params

        if @candidate_requirements_choice.valid?
          current_school_profile.update! \
            candidate_requirements_choice: @candidate_requirements_choice,
            candidate_requirements_selection_step_completed: false

          redirect_to next_step_path(current_school_profile)
        else
          render :edit
        end
      end

    private

      def candidate_requirements_choice_params
        params.require(:schools_on_boarding_candidate_requirements_choice).permit \
          :has_requirements
      end
    end
  end
end
