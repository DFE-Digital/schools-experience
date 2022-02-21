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

          continue(current_school_profile)
        else
          render :new
        end
      end

      def edit
        @access_needs_support = current_school_profile.access_needs_support
      end

      def update
        @access_needs_support = \
          AccessNeedsSupport.new admin_needs_support_params

        if @access_needs_support.valid?
          current_school_profile.update! \
            access_needs_support: @access_needs_support

          continue(current_school_profile)
        else
          render :edit
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
