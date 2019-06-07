module Candidates
  class UnauthorizedCandidate < RuntimeError; end

  class DashboardBaseController < ApplicationController
    before_action :authenticate_user!
    rescue_from UnauthorizedCandidate, with: -> { redirect_to candidates_signin_path }

  protected

    def current_user
      return nil unless session[:gitis_contact]

      @current_user ||= Bookings::Gitis::Contact.new(session[:gitis_contact])
    end

    def current_user=(contact)
      contact.tap do |c|
        session[:gitis_contact] = c.attributes
      end
    end

    def authenticate_user!
      current_user || fail(UnauthorizedCandidate)
    end
  end
end
