require 'rails_helper'
require_relative 'session_context'

describe Schools::SessionsController, type: :request do
  include_context "logged in DfE user"
  context '#new' do
    before { get new_schools_switch_path }

    specify 'should clear the user from the session' do
      expect(session[:current_user]).to be_nil
    end

    specify 'should redirect to the dashboard' do
      expect(subject).to redirect_to(schools_dashboard_path)
    end
  end
end
