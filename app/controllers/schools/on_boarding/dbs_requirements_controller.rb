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

          continue(current_school_profile)
        else
          render :new
        end
      end

      def edit
        # NB: we must initialise new models when editing an existing one because
        # we are using the composed_of framework to build the components of
        # SchoolProfile. Otherwise, frozen variable errors will be triggered.
        @dbs_requirement = DbsRequirement.new(current_school_profile.dbs_requirement.attributes)
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

          continue(current_school_profile)
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
          :dbs_policy_conditions,
          :dbs_policy_details,
          :dbs_policy_details_inschool
      end
    end
  end
end
