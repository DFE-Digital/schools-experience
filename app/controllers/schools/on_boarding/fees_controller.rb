module Schools
  module OnBoarding
    class FeesController < OnBoardingsController
      before_action do
        @requires_dbs_check = current_school_profile.dbs_requirement.requires_check
      end

      def new
        @fees = current_school_profile.fees
      end

      def create
        @fees = Fees.new fees_params

        if @fees.valid?
          current_school_profile.update! fees: @fees
          redirect_to next_step_path(current_school_profile)
        else
          render :new
        end
      end

      def edit
        @fees = current_school_profile.fees
      end

      def update
        @fees = Fees.new fees_params

        if @fees.valid?
          current_school_profile.fees = @fees
          current_school_profile.administration_fee_step_completed = false if @fees.administration_fees?
          current_school_profile.dbs_fee_step_completed            = false if @fees.dbs_fees?
          current_school_profile.other_fee_step_completed          = false if @fees.other_fees?
          current_school_profile.save!
          redirect_to next_step_path(current_school_profile)
        else
          render :edit
        end
      end

    private

      def fees_params
        params.require(:schools_on_boarding_fees).permit \
          :administration_fees,
          :dbs_fees,
          :other_fees
      end
    end
  end
end
