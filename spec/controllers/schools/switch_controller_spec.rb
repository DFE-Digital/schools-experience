require 'rails_helper'
require_relative 'session_context'

describe Schools::SessionsController, type: :request do
  include_context "logged in DfE user"
  context '#new' do
    context 'when in-app school changing is enabled' do
      before do
        allow(Schools::ChangeSchool).to receive(:allow_school_change_in_app?).and_return(true)
      end

      subject { get new_schools_switch_path }

      it { expect(subject).to redirect_to(schools_change_path) }
    end

    context 'when in-app school changing is disabled' do
      before do
        allow(Schools::ChangeSchool).to receive(:allow_school_change_in_app?).and_return(false)
      end

      before { get new_schools_switch_path }

      specify 'should clear the user from the session' do
        expect(session[:current_user]).to be_nil
        expect(session[:school_name]).to be_nil
        expect(session[:other_urns]).to be_nil
      end

      specify 'should redirect to the dashboard' do
        expect(subject).to redirect_to(schools_dashboard_path)
      end
    end
  end
end
