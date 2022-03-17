module Schools
  module OnBoarding
    class ConfirmationsController < OnBoardingsController
      def show
        redirect_to schools_on_boarding_profile_path if reloaded_create_action?
      end

      def create
        @confirmation = Confirmation.new confirmation_params

        if @confirmation.valid?
          current_school_profile.update! confirmation: @confirmation
          publish_profile!
          redirect_to schools_on_boarding_confirmation_path
        else
          @school = current_school_profile.bookings_school
          @profile = SchoolProfilePresenter.new(current_school_profile)
          render 'schools/on_boarding/profiles/onboarding'
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

      def bookings_profile
        @bookings_profile ||= current_school.profile
      end

      # If the user clicks submit on the previous step without accepting the
      # ts and cs then reloads the page they will see the confirmation page
      # (same url different methods), we want to prevent that behaviour.
      def reloaded_create_action?
        bookings_profile.nil? || latest_changes_havent_been_published?
      end

      def latest_changes_havent_been_published?
        bookings_profile.updated_at < current_school_profile.updated_at
      end
    end
  end
end
