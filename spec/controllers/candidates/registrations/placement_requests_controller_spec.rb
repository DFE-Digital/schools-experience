require 'rails_helper'

describe Candidates::Registrations::PlacementRequestsController, type: :request do
  include_context 'Stubbed candidates school'

  let :uuid do
    'some-uuid'
  end

  before do
    allow(Candidates::Registrations::RegistrationStore).to \
      receive(:instance) { registration_store }
  end

  context '#create' do
    before do
      allow(Candidates::Registrations::PlacementRequestJob).to \
        receive(:perform_later) { true }

      get \
        "/candidates/schools/URN/registrations/placement_request/new?uuid=#{uuid}"
    end

    context 'uuid not found' do
      let :registration_store do
        double Candidates::Registrations::RegistrationStore, \
          has_registration?: false
      end

      it 'renders the session expired view' do
        expect(response).to render_template :session_expired
      end
    end

    context 'uuid found' do
      let :registration_store do
        double Candidates::Registrations::RegistrationStore, \
          has_registration?: true
      end

      it 'enqueues the placement request job' do
        expect(Candidates::Registrations::PlacementRequestJob).to \
          have_received(:perform_later).with uuid
      end

      it 'redirects to placement request show' do
        expect(response).to redirect_to \
          candidates_school_registrations_placement_request_path(
            'URN',
            uuid: uuid
          )
      end
    end
  end

  context '#show' do
    context 'uuid not found' do
      let :registration_store do
        double Candidates::Registrations::RegistrationStore
      end

      before do
        allow(registration_store).to receive(:retrieve!) do
          raise Candidates::Registrations::RegistrationStore::SessionNotFound
        end

        get \
          "/candidates/schools/URN/registrations/placement_request?uuid=#{uuid}"
      end

      it 'renders the session expired view' do
        expect(response).to render_template :session_expired
      end
    end

    context 'uuid found' do
      let :registration_session do
        FactoryBot.build :registration_session
      end

      let :registration_store do
        double Candidates::Registrations::RegistrationStore,
          retrieve!: registration_session
      end

      before do
        get \
          "/candidates/schools/URN/registrations/placement_request?uuid=#{uuid}"
      end

      it 'renders the show template' do
        expect(response).to render_template :show
      end
    end
  end
end
