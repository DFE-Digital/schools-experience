module Schools
  module OnBoarding
    class FeesController < OnBoardingsController
      def new
        @fees = Fees.new
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
          current_school_profile.update! fees: @fees
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
