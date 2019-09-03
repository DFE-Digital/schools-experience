module Schools
  module OnBoarding
    class OtherFeesController < OnBoardingsController
      def new
        @other_fee = current_school_profile.other_fee
      end

      def create
        @other_fee = OtherFee.new other_fee_params

        if @other_fee.valid?
          current_school_profile.update! \
            other_fee: @other_fee,
            other_fee_step_completed: true

          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

    private

      def other_fee_params
        params.require(:schools_on_boarding_other_fee).permit \
          :amount_pounds,
          :description,
          :interval,
          :payment_method
      end
    end
  end
end
