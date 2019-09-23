module Schools
  module Errors
    # user can log in via DfE Sign-in but doesn't have the 'School
    # Experience Administrator' role
    class InsufficientPrivilegesController < ApplicationController
      def show; end
    end
  end
end
