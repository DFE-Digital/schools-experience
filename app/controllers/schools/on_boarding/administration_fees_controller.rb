module Schools
  module OnBoarding
    class AdministrationFeesController < OnBoardingsController
      def new
        @administration_fee = current_school_profile.administration_fee
      end

      def create
        @administration_fee = AdministrationFee.new administration_fee_params

        if @administration_fee.valid?
          current_school_profile.update! \
            administration_fee: @administration_fee,
            administration_fee_step_completed: true

          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

    private

      def administration_fee_params
        params.require(:schools_on_boarding_administration_fee).permit \
          :amount_pounds,
          :description,
          :interval,
          :payment_method
      end
    end
  end
end
