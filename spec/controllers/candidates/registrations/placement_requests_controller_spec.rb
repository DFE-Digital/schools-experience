require 'rails_helper'

describe Candidates::Registrations::PlacementRequestsController, type: :request do
  include_context 'Stubbed candidates school'

  let :registration_session do
    FactoryBot.build :registration_session, urn: school.urn
  end

  let :uuid do
    registration_session.uuid
  end

  before do
    Candidates::Registrations::RegistrationStore.instance.store! \
      registration_session

    allow(Candidates::Registrations::PlacementRequestJob).to \
      receive(:perform_later) { true }
  end

  context '#create' do
    before :each do
      @placement_request_count = Bookings::PlacementRequest.count
    end

    context 'uuid not found' do
      before do
        get "/candidates/confirm/bad-uuid"
      end

      it "doesn't create a new PlacementRequest" do
        expect(Bookings::PlacementRequest.count).to \
          eq @placement_request_count
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
        get "/candidates/confirm/#{uuid}"
      end

      context 'registration job already enqueued' do
        before do
          @placement_request_count = Bookings::PlacementRequest.count
          get "/candidates/confirm/#{uuid}"
        end

        it "doesn't create a new PlacementRequest" do
          expect(Bookings::PlacementRequest.count).to \
            eq @placement_request_count
        end

        it "doesn't requeue a PlacementRequestJob" do
          expect(Candidates::Registrations::PlacementRequestJob).to \
            have_received(:perform_later).exactly(:once)
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
        let :stored_registration_session do
          Candidates::Registrations::RegistrationStore.instance.retrieve! uuid
        end

        it 'marks the registration as completed and re-stores it in redis' do
          expect(stored_registration_session).to be_completed
        end

        it 'creates a bookings placement request' do
          expect(Bookings::PlacementRequest.count).to \
            eq @placement_request_count + 1
          expect(Bookings::PlacementRequest.last.school).to \
            eq stored_registration_session.school
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
      before do
        get \
          "/candidates/schools/URN/registrations/placement_request?uuid=bad-uuid"
      end

      it 'renders the session expired view' do
        expect(response).to render_template :session_expired
      end
    end

    context 'uuid found' do
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
