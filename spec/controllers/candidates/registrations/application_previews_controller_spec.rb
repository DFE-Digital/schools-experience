require 'rails_helper'

describe Candidates::Registrations::ApplicationPreviewsController, type: :request do
  include_context 'with a stubbed candidate school'
  include_context 'with a stubbed current registration'

  describe '#show' do
    before do
      get '/candidates/schools/urn/registrations/application_preview'
    end

    context 'when candidate skipped ahead' do
      let :registration_session do
        FactoryBot.build :registration_session, urn: school.urn, with: []
      end

      it 'redirects to the first missing step' do
        expect(response).to redirect_to \
          "/candidates/schools/#{school.urn}/registrations/personal_information/new"
      end
    end

    context 'when candidate has not skipped ahead' do
      let :registration_session do
        FactoryBot.build :registration_session
      end

      it 'renders the show template' do
        expect(response).to render_template :show
      end
    end
  end
end
