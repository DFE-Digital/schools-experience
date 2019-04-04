require 'rails_helper'
require_relative 'session_context'

describe Schools::SessionsController, type: :request do
  context '#destroy' do
    include_context "logged in DfE user"
    subject { delete schools_session_path }

    specify "should clear the session" do
      subject
      expect(session).to be_empty
    end

    specify "should redirect to the homepage" do
      expect(subject).to redirect_to(root_path)
    end
  end
end
