module Schools
  module OnBoarding
    class FeesController < OnBoardingsController
      before_action do
        @requires_dbs_check = current_school_profile.dbs_requirement.requires_check
      end

      def new
        @fees = Fees.new(current_school_profile.fees.attributes)
      end

      def create
        @fees = Fees.new fees_params
        if @fees.valid?
          current_school_profile.update! fees: @fees
          continue(current_school_profile)
        else
          render :new
        end
      end

      def edit
        # NB: we must initialise new models when editing an existing one because
        # we are using the composed_of framework to build the components of
        # SchoolProfile. Otherwise, frozen variable errors will be triggered.
        @fees = Fees.new(current_school_profile.fees.attributes)
      end

      def update
        @fees = Fees.new fees_params

        if @fees.valid?
          current_school_profile.fees = @fees
          current_school_profile.administration_fee_step_completed = false if @fees.administration_fees?
          current_school_profile.dbs_fee_step_completed            = false if @fees.dbs_fees?
          current_school_profile.other_fee_step_completed          = false if @fees.other_fees?
          current_school_profile.save!
          continue(current_school_profile)
        else
          render :edit
        end
      end

    private

      def fees_params
        params.require(:schools_on_boarding_fees).permit(selected_fees: [])
      end
    end
  end
end
