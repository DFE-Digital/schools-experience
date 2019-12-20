module Schools
  class SwitchController < ApplicationController
    # Remove the current session and redirect to the dashboard, this will
    # trigger the standard OIDC flow
    #
    # Because the user is already logged in to DSI they won't get asked for
    # their username and password but will be prompted to pick an org from a
    # list
    #
    # That should result in a valid auth response and they should be bounced
    # back to the dashboard with a session associated to their new school
    def new
      return redirect_to(schools_change_path) if Schools::ChangeSchool.allow_school_change_in_app?

      session[:current_user] = nil
      session[:school_name]  = nil
      session[:other_urns]   = nil

      redirect_to(schools_dashboard_path)
    end

    def show
      @current_school = Bookings::School.find_by(urn: session[:urn])
      @other_school   = Bookings::School.find_by(urn: params[:urn])
    end
  end
end
