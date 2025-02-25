module Schools
  module OnBoarding
    class OtherFeesController < OnBoardingsController
      def new
        @other_fee = duplicate_if_frozen(current_school_profile.other_fee)
      end

      def edit
        @other_fee = duplicate_if_frozen(current_school_profile.other_fee)
        render :new
      end

      def create
        @other_fee = OtherFee.new other_fee_params

        if @other_fee.valid?
          current_school_profile.update! \
            other_fee: @other_fee,
            other_fee_step_completed: true

          continue(current_school_profile)
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
