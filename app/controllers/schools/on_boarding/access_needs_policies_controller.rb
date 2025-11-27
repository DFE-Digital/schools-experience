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

          continue(current_school_profile)
        else
          render :new
        end
      end

      def edit
        # NB: we must initialise new models when editing an existing one because
        # we are using the composed_of framework to build the components of
        # SchoolProfile. Otherwise, frozen variable errors will be triggered.
        @access_needs_policy = AccessNeedsPolicy.new(current_school_profile.access_needs_policy.attributes)
      end

      def update
        @access_needs_policy = AccessNeedsPolicy.new access_needs_policy_params

        if @access_needs_policy.valid?
          current_school_profile.update! \
            access_needs_policy: @access_needs_policy

          continue(current_school_profile)
        else
          render :edit
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
