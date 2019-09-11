module Schools
  module OnBoarding
    class CandidateRequirementsSelectionsController < OnBoardingsController
      def new
        @candidate_requirements_selection = \
          current_school_profile.candidate_requirements_selection
      end

      def create
        @candidate_requirements_selection = \
          CandidateRequirementsSelection.new candidate_requirements_selection_params

        if @candidate_requirements_selection.valid?
          current_school_profile.update! \
            candidate_requirements_selection: @candidate_requirements_selection,
            candidate_requirements_selection_step_completed: true

          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

      def edit
        @candidate_requirements_selection = \
          current_school_profile.candidate_requirements_selection
      end

      def update
        @candidate_requirements_selection = \
          CandidateRequirementsSelection.new candidate_requirements_selection_params

        if @candidate_requirements_selection.valid?
          current_school_profile.update! \
            candidate_requirements_selection: @candidate_requirements_selection

          redirect_to next_step_path(current_school_profile)
        else
          render :edit
        end
      end

    private

      def candidate_requirements_selection_params
        params.require(:schools_on_boarding_candidate_requirements_selection).permit \
          :on_teacher_training_course,
          :not_on_another_training_course,
          :has_or_working_towards_degree,
          :live_locally,
          :maximum_distance_from_school,
          :other,
          :other_details
      end
    end
  end
end
