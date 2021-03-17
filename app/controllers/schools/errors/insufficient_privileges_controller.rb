module Schools
  module Errors
    # user can log in via DfE Sign-in but doesn't have the 'School
    # Experience Administrator' role
    class InsufficientPrivilegesController < ApplicationController
      def show
        @organisation_access_url = signin_config(:request_organisation_url)
      end

    private

      def signin_config(key)
        Rails.application.config.x.send :"dfe_sign_in_#{key}"
      end
    end
  end
end
