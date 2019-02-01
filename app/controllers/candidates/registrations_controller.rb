module Candidates
  class RegistrationsController < ApplicationController
  private

    def current_registration
      session[:registration] ||= {}
    end
  end
end
