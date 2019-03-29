module Schools
  module OnBoarding
    class DbsFeesController < OnBoardingsController
      def new
        @dbs_fee = DBSFee.new
      end

      def create
        @dbs_fee = DBSFee.new dbs_fee_params

        if @dbs_fee.valid?
          current_school_profile.update! dbs_fee: @dbs_fee
          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

    private

      def dbs_fee_params
        params.require(:schools_on_boarding_dbs_fee).permit \
          :amount_pounds,
          :description,
          :interval,
          :payment_method
      end
    end
  end
end
