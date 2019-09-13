module Schools
  module OnBoarding
    class AccessNeedsPoliciesController < OnBoardingsController
      def new
        @access_needs_policy = AccessNeedsPolicy.new
      end

      def create
        @access_needs_policy = AccessNeedsPolicy.new access_needs_policy_params

        if @access_needs_policy.valid?
          current_school_profile.update! \
            access_needs_policy: @access_needs_policy

          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

    private

      def access_needs_policy_params
        params.require(:schools_on_boarding_access_needs_policy).permit \
          :has_access_needs_policy,
          :url
      end
    end
  end
end
