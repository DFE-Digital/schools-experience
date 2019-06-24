require 'rails_helper'

describe Candidates::Registrations::ApplicationPreviewsController, type: :request do
  include_context 'Stubbed candidates school'
  include_context 'Stubbed current_registration'

  context '#show' do
    before do
      get '/candidates/schools/urn/registrations/application_preview'
    end

    context 'candidate skipped ahead' do
      let :registration_session do
        Candidates::Registrations::RegistrationSession.new({})
      end

      it 'redirects to the first missing step' do
        expect(response).to redirect_to \
          '/candidates/schools/urn/registrations/placement_preference/new'
      end
    end

    context 'candidate has not skipped ahead' do
      let :registration_session do
        FactoryBot.build :registration_session
      end

      it 'renders the show template' do
        expect(response).to render_template :show
      end
    end
  end
end
