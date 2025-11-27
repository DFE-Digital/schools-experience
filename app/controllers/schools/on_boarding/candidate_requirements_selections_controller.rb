module Schools
  module OnBoarding
    class CandidateRequirementsSelectionsController < OnBoardingsController
      def new
        @candidate_requirements_selection = \
          CandidateRequirementsSelection.new(current_school_profile.candidate_requirements_selection.attributes)
      end

      def create
        @candidate_requirements_selection = \
          CandidateRequirementsSelection.new candidate_requirements_selection_params

        if @candidate_requirements_selection.valid?
          current_school_profile.update! \
            candidate_requirements_selection: @candidate_requirements_selection,
            candidate_requirements_selection_step_completed: true

          continue(current_school_profile)
        else
          render :new
        end
      end

      def edit
        # NB: we must initialise new models when editing an existing one because
        # we are using the composed_of framework to build the components of
        # SchoolProfile. Otherwise, frozen variable errors will be triggered.
        @candidate_requirements_selection = CandidateRequirementsSelection.new \
          current_school_profile.candidate_requirements_selection.attributes
      end

      def update
        @candidate_requirements_selection = \
          CandidateRequirementsSelection.new candidate_requirements_selection_params

        if @candidate_requirements_selection.valid?
          current_school_profile.update! \
            candidate_requirements_selection: @candidate_requirements_selection

          continue(current_school_profile)
        else
          render :edit
        end
      end

    private

      def candidate_requirements_selection_params
        params.require(:schools_on_boarding_candidate_requirements_selection).permit(
          :maximum_distance_from_school,
          :photo_identification_details,
          :other_details,
          selected_requirements: []
        )
      end
    end
  end
end
