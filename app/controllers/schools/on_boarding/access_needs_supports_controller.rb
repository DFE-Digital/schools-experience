module Schools
  module OnBoarding
    class AccessNeedsSupportsController < OnBoardingsController
      def new
        @access_needs_support = AccessNeedsSupport.new
      end

      def create
        @access_needs_support = \
          AccessNeedsSupport.new admin_needs_support_params

        if @access_needs_support.valid?
          current_school_profile.update! \
            access_needs_support: @access_needs_support

          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

    private

      def admin_needs_support_params
        params.require(:schools_on_boarding_access_needs_support).permit \
          :supports_access_needs
      end
    end
  end
end
