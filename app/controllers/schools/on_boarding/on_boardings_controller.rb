module Schools
  module OnBoarding
    class OnBoardingsController < BaseController
    private

      def current_school_profile
        # TODO pull urn from BaseController#current_school
        @current_school_profile ||= Schools::SchoolProfile.find_or_create_by! urn: 'URN'
      end
    end
  end
end
