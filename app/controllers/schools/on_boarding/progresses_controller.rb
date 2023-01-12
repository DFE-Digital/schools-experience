module Schools
  module OnBoarding
    class ProgressesController < OnBoardingsController
      def show
        @wizard = OnBoarding::Wizard.new(current_school_profile)
        @prepopulate_school_profile = Schools::PrepopulateSchoolProfile.new(
          current_school,
          school_uuids(reload: true)
        )
      end
    end
  end
end
