module Schools
  module OnBoarding
    class DbsFeesController < OnBoardingsController
      def new
        @dbs_fee = DBSFee.new(current_school_profile.dbs_fee.attributes)
      end

      def edit
        # NB: we must initialise new models when editing an existing one because
        # we are using the composed_of framework to build the components of
        # SchoolProfile. Otherwise, frozen variable errors will be triggered.
        @dbs_fee = DBSFee.new(current_school_profile.dbs_fee.attributes)
        render :new
      end

      def create
        @dbs_fee = DBSFee.new dbs_fee_params

        if @dbs_fee.valid?
          current_school_profile.update! \
            dbs_fee: @dbs_fee,
            dbs_fee_step_completed: true

          continue(current_school_profile)
        else
          render :new
        end
      end

    private

      def dbs_fee_params
        params.require(:schools_on_boarding_dbs_fee).permit \
          :amount_pounds,
          :description,
          :payment_method
      end
    end
  end
end
