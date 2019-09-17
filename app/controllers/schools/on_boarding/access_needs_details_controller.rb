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

          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

      def edit
        @access_needs_detail = current_school_profile.access_needs_detail
      end

      def update
        @access_needs_detail = AccessNeedsDetail.new access_needs_detail_params

        if @access_needs_detail.valid?
          current_school_profile.update! \
            access_needs_detail: @access_needs_detail

          redirect_to next_step_path(current_school_profile)
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
