module Schools
  class PrepopulateSchoolProfilesController < BaseController
    skip_before_action :ensure_onboarded

    def create
      @prepopulate_school_profile = Schools::PrepopulateSchoolProfile.new(
        current_school,
        school_uuids(reload: true),
        prepopulate_school_profile_params
      )

      if @prepopulate_school_profile.valid?
        @prepopulate_school_profile.prepopulate!
        flash.notice = "Your profile has been prepopulated."
      end

      redirect_to :schools_on_boarding_progress
    end

  private

    def prepopulate_school_profile_params
      params.fetch(:schools_prepopulate_school_profile, {}).permit(:prepopulate_from_urn)
    end
  end
end
