module Schools
  module OnBoarding
    class ConfirmationsController < OnBoardingsController
      def show; end

      def create
        @confirmation = Confirmation.new confirmation_params

        if @confirmation.valid?
          current_school_profile.update! confirmation: @confirmation
          publish_profile!
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

      def publish_profile!
        school = current_school_profile.bookings_school
        Bookings::ProfilePublisher.new(school, current_school_profile).update!
      end
    end
  end
end
