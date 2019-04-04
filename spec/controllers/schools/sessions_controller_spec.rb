require 'rails_helper'
require_relative 'session_context'

describe Schools::SessionsController, :type => :request do

  # triggered by auth service calling back to /auth/callback
  # which is aimed here
  context '#create' do
  # context 'redirection' do
  #   let(:return_url) { '/schools/dashboard' }
  #
  #   let(:state) { 'd18ce84b-423e-4696-bee4-b74caa47163e' }
  #   let(:code) { 'OTA4MTU0ZTgtMjBhZC00YmNmLThmMmQtOGZiZDhmNTYxMTA2vLY8wh-MpR-WR3vsn4C2J_oBkN-KGjD9-XVcDFS8UyADwt5DrIrYe0Gjgsj2gpvAt5L2cka5n8ZZmiojr6zgWg' }
  #   let(:session_state) { '652b5afc63d7c4875c42de4231f66e4940226f840b2a7ea02441544751ea0a2a.h3bd7bc2438a84dc' }
  #
  #   before do
  #     allow_any_instance_of(ActionDispatch::Request)
  #       .to receive(:session).and_return(
  #         return_url: return_url,
  #         state: state
  #     )
  #
  #     allow_any_instance_of(OpenIDConnect::Client)
  #       .to receive(:access_token!).and_return(
  #         OpenIDConnect::AccessToken.new(
  #           client: OpenIDConnect::Client.new(identifier: 'abc123'),  access_token: 'abc123'
  #         )
  #     )
  #   end
  #
  #   let(:callback) { "/auth/callback?code=#{code}&state=#{state}&session_state=#{session_state}" }
  #
  #   subject { get callback }
  #
  #   specify 'should do the thing' do
  #     expect(subject).to redirect_to(return_url)
  #   end
  # end
  end

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
