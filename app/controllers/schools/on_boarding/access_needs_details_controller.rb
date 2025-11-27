module Schools
  module OnBoarding
    class AccessNeedsDetailsController < OnBoardingsController
      def new
        @access_needs_detail = AccessNeedsDetail.new.tap(&:add_default_copy!)
      end

      def create
        @access_needs_detail = AccessNeedsDetail.new access_needs_detail_params

        if @access_needs_detail.valid?
          current_school_profile.update! \
            access_needs_detail: @access_needs_detail

          continue(current_school_profile)
        else
          render :new
        end
      end

      def edit
        # NB: we must initialise new models when editing an existing one because
        # we are using the composed_of framework to build the components of
        # SchoolProfile. Otherwise, frozen variable errors will be triggered.
        @access_needs_detail = AccessNeedsDetail.new(current_school_profile.access_needs_detail.attributes)
      end

      def update
        @access_needs_detail = AccessNeedsDetail.new access_needs_detail_params

        if @access_needs_detail.valid?
          current_school_profile.update! \
            access_needs_detail: @access_needs_detail

          continue(current_school_profile)
        else
          render :edit
        end
      end

    private

      def access_needs_detail_params
        params.require(:schools_on_boarding_access_needs_detail).permit \
          :description
      end
    end
  end
end
