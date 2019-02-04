module Candidates
  class RegistrationsController < ApplicationController
  private

    def persist(model)
      current_registration[model.model_name.param_key] = model.attributes
    end

    def current_registration
      session[:registration] ||= {}
    end

    def current_school
      'URN'
    end
    helper_method :current_school
  end
end
