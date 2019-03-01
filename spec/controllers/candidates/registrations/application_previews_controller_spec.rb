require 'rails_helper'

describe Candidates::Registrations::ApplicationPreviewsController, type: :request do
  include_context 'Stubbed candidates school'

  let! :uncompleted_registration_session do
    Candidates::Registrations::RegistrationSession.new({})
  end

  let! :completed_registration_session do
    FactoryBot.build :registration_session
  end

  context '#show' do
    before do
      allow(Candidates::Registrations::RegistrationSession).to receive :new do
        registration_session
      end

      get '/candidates/schools/urn/registrations/application_preview'
    end

    context 'candidate skipped ahead' do
      let :registration_session do
        uncompleted_registration_session
      end

      it 'redirects to the first missing step' do
        expect(response).to redirect_to \
          '/candidates/schools/urn/registrations/contact_information/new'
      end
    end

    context 'candidate has not skipped ahead' do
      let :registration_session do
        completed_registration_session
      end

      it 'renders the show template' do
        expect(response).to render_template :show
      end
    end
  end
end
