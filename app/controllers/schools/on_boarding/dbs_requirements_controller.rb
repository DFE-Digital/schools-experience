module Schools
  module OnBoarding
    class DbsRequirementsController < OnBoardingsController
      def new
        @dbs_requirement = DbsRequirement.new
      end

      def create
        @dbs_requirement = DbsRequirement.new dbs_requirement_params

        if @dbs_requirement.valid?
          current_school_profile.update! dbs_requirement: @dbs_requirement

          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

    private

      def dbs_requirement_params
        params.require(:schools_on_boarding_dbs_requirement).permit \
          :requires_check,
          :dbs_policy_details,
          :no_dbs_policy_details
      end
    end
  end
end
