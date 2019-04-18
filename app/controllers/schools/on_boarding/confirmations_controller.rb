module Schools
  module OnBoarding
    class ConfirmationsController < OnBoardingsController
      def show; end

      def create
        @confirmation = Confirmation.new confirmation_params

        if @confirmation.valid?
          redirect_to schools_on_boarding_confirmation_path
        else
          @profile = SchoolProfilePresenter.new(current_school_profile)
          render 'schools/on_boarding/profiles/show'
        end
      end

    private

      def confirmation_params
        params.require(:schools_on_boarding_confirmation).permit :acceptance
      end
    end
  end
end
