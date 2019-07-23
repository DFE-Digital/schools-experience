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
          # TODO remove duplication
          # NOTE bug, -> submit with error, hit here, refresh -> see confirmation
          # without having confirmed.
          @school = current_school_profile.bookings_school
          set_up_school_for_preview! @school

          profile = Bookings::Profile.new converter.attributes
          @presenter = Candidates::SchoolPresenter.new @school, profile
          render 'schools/on_boarding/previews/show'
        end
      end

    private

      def set_up_school_for_preview!(school)
        school.phase_ids = converter.phase_ids
        school.subject_ids = current_school_profile.subject_ids
      end

      def converter
        @converter ||= Bookings::ProfileAttributesConvertor.new current_school_profile.attributes
      end

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
