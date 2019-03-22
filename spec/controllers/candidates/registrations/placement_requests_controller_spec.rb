require 'rails_helper'

describe Candidates::Registrations::PlacementRequestsController, type: :request do
  include_context 'Stubbed candidates school'

  let :uuid do
    'some-uuid'
  end

  let :registration_store do
    double Candidates::Registrations::RegistrationStore,
      retrieve!: registration_session,
      store!: 1
  end

  before do
    allow(Candidates::Registrations::RegistrationStore).to \
      receive(:instance) { registration_store }
  end

  context '#create' do
    context 'uuid not found' do
      let :registration_session do
        nil
      end

      before do
        allow(Candidates::Registrations::PlacementRequestJob).to \
          receive(:perform_later) { true }

        allow(registration_store).to receive(:retrieve!) do
          raise Candidates::Registrations::RegistrationStore::SessionNotFound
        end

        get "/candidates/confirm?uuid=#{uuid}"
      end

      it "doesn't queue a PlacementRequestJob" do
        expect(Candidates::Registrations::PlacementRequestJob).not_to \
          have_received :perform_later
      end

      it 'renders the session expired view' do
        expect(response).to render_template :session_expired
      end
    end

    context 'uuid found' do
      before do
        allow(Candidates::Registrations::PlacementRequestJob).to \
          receive(:perform_later) { true }

        get "/candidates/confirm?uuid=#{uuid}"
      end

      context 'registration job already enqueued' do
        let :registration_session do
          double Candidates::Registrations::RegistrationSession,
            completed?: true,
            uuid: uuid,
            school: school
        end

        it "doesn't queue a PlacementRequestJob" do
          expect(Candidates::Registrations::PlacementRequestJob).not_to \
            have_received :perform_later
        end

        it 'redirects to placement request show' do
          expect(response).to redirect_to \
            candidates_school_registrations_placement_request_path(
              school,
              uuid: uuid
            )
        end
      end

      context 'registration job not already enqueued' do
        let :registration_session do
          double Candidates::Registrations::RegistrationSession,
            completed?: false,
            flag_as_completed!: true,
            uuid: uuid,
            school: school
        end

        it 'marks the registration as completed' do
          expect(registration_session).to have_received :flag_as_completed!
        end

        it 're-stores the updated registration in the registration_store' do
          expect(registration_store).to have_received(:store!).with \
            registration_session
        end

        it 'enqueues the placement request job' do
          expect(Candidates::Registrations::PlacementRequestJob).to \
            have_received(:perform_later).with uuid
        end

        it 'redirects to placement request show' do
          expect(response).to redirect_to \
            candidates_school_registrations_placement_request_path(
              school,
              uuid: uuid
            )
        end
      end
    end
  end

  context '#show' do
    context 'uuid not found' do
      let :registration_session do
        nil
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
