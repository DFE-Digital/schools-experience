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

      def edit
        @dbs_requirement = current_school_profile.dbs_requirement
      end

      def update
        @dbs_requirement = DbsRequirement.new dbs_requirement_params

        if @dbs_requirement.valid?

          if dbs_has_been_toggled_on?
            # prompt the user to select if they charge dbs fees
            current_school_profile.fees_dbs_fees = nil
          elsif dbs_has_been_toggled_off?
            # dont allow charging a dbs fee if the school doesnt offer dbs
            current_school_profile.fees_dbs_fees = false
          end

          current_school_profile.update! dbs_requirement: @dbs_requirement

          redirect_to next_step_path(current_school_profile)
        else
          render :edit
        end
      end

    private

      def dbs_has_been_toggled_on?
        @dbs_requirement.requires_check == true &&
          current_school_profile.dbs_requirement.requires_check == false
      end

      def dbs_has_been_toggled_off?
        @dbs_requirement.requires_check == false &&
          current_school_profile.dbs_requirement.requires_check == true
      end

      def dbs_requirement_params
        params.require(:schools_on_boarding_dbs_requirement).permit \
          :requires_check,
          :dbs_policy_details
      end
    end
  end
end
