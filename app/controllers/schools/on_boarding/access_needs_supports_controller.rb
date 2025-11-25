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
        # NB: we must initialise new models when editing an existing one because
        # we are using the composed_of framework to build the components of
        # SchoolProfile. Otherwise, frozen variable errors will be triggered.
        @access_needs_support = AccessNeedsSupport.new(current_school_profile.access_needs_support.attributes)
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
