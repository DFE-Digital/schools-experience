module Schools
  module OnBoarding
    class CandidateRequirementsController < OnBoardingsController
      def new
        @candidate_requirement = CandidateRequirement.new
      end

      def create
        @candidate_requirement = CandidateRequirement.new \
          candidate_requirement_params

        if @candidate_requirement.valid?
          current_school_profile.update! \
            candidate_requirement: @candidate_requirement

          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

      def edit
        @candidate_requirement = current_school_profile.candidate_requirement
      end

      def update
        @candidate_requirement = CandidateRequirement.new \
          candidate_requirement_params

        if @candidate_requirement.valid?
          current_school_profile.update! \
            candidate_requirement: @candidate_requirement

          redirect_to next_step_path(current_school_profile)
        else
          render :edit
        end
      end

    private

      def candidate_requirement_params
        params.require(:schools_on_boarding_candidate_requirement).permit \
          :dbs_requirement,
          :dbs_policy,
          :requirements,
          :requirements_details
      end
    end
  end
end
