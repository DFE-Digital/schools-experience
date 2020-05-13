require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe SchoolsController, type: :request do
  describe '#show' do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('DFE_SIGNIN_DEACTIVATED') { toggle }
    end

    subject {
      get '/schools'
      response
    }

    context 'when sign in is enabled' do
      let(:toggle) { 'false' }

      specify 'should render the correct template' do
        is_expected.to have_rendered :show
      end

      specify 'should show login button' do
        expect(subject.body).to match %r{govuk-button--start}
      end

      specify 'should not show disabled message' do
        expect(subject.body).not_to match %r{id="dfe-sigin-deactivated}
      end
    end

    context 'when sign in is disabled with default message' do
      let(:toggle) { '1' }

      specify 'should render the correct template' do
        is_expected.to have_rendered :show
      end

      specify 'should not show login button' do
        expect(subject.body).not_to match %r{govuk-button--start}
      end

      specify 'should show disabled message' do
        expect(subject.body).to match %r{id="dfe-signin-deactivated}
      end

      specify 'should show default message' do
        expect(subject.body).to match %r{use this service later today}
      end
    end

    context 'when sign in is disabled with custom message' do
      let(:toggle) { 'custom message' }

      specify 'should render the correct template' do
        is_expected.to have_rendered :show
      end

      specify 'should not show login button' do
        expect(subject.body).not_to match %r{govuk-button--start}
      end

      specify 'should show disabled message' do
        expect(subject.body).to match %r{id="dfe-signin-deactivated}
      end

      specify 'should show custom message' do
        expect(subject.body).to match %r{custom message}
      end
    end
  end
end
