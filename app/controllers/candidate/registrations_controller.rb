class Candidate::RegistrationsController < ApplicationController
private

  def current_registration
    session[:registration] ||= {}
  end
end
