module Schools
  module Errors
    # user has attempted to change to this school but the urn wasn't
    # returned in their list of allowed urns (from the DfE Sign-in API)
    class InaccessibleSchoolController < ApplicationController
      def show; end
    end
  end
end
