require 'rails_helper'

describe Candidates::Registrations::PlacementRequestsController, type: :request do
  include_context 'Stubbed candidates school'
  include_context "api latest privacy policy"
  include_context "api teaching subjects"

  let :registration_session do
    FactoryBot.build :registration_session, urn: school.urn
  end

  let :uuid do
    registration_session.uuid
  end

  let :school_experience do
    instance_double(Bookings::Gitis::SchoolExperience)
  end

  before do
    Candidates::Registrations::RegistrationStore.instance.store! \
      registration_session

    allow(Candidates::Registrations::PlacementRequestJob).to \
      receive(:perform_later) { true }

    allow(Bookings::Gitis::SchoolExperience).to \
      receive(:from_placement_request) { school_experience }

    allow(school_experience).to \
      receive(:write_to_gitis_contact)
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
      context 'registration job already enqueued' do
        before do
          get "/candidates/confirm/#{uuid}"
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
        shared_examples 'a successful create' do
          before do
            get "/candidates/confirm/#{uuid}"
          end

          let :stored_registration_session do
            Candidates::Registrations::RegistrationStore.instance.retrieve! uuid
          end

          it 'marks the registration as completed and re-stores it in redis' do
            expect(stored_registration_session).to be_completed
          end

          it "creates a candidate" do
            expect(Bookings::Candidate.count).to eq(1)
          end

          it "assigns contact attrs" do
            expect(session['gitis_contact']).to include \
              firstName: stored_registration_session.personal_information.first_name,
              lastName: stored_registration_session.personal_information.last_name
          end

          it 'creates a bookings placement request' do
            expect(Bookings::PlacementRequest.count).to \
              eq @placement_request_count + 1
            expect(Bookings::PlacementRequest.last.school).to \
              eq stored_registration_session.school
          end

          it 'enqueues the placement request job' do
            expect(Candidates::Registrations::PlacementRequestJob).to \
              have_received(:perform_later).with \
                uuid,
                candidates_cancel_url(Bookings::PlacementRequest.last.token),
                schools_placement_request_url(Bookings::PlacementRequest.last)
          end

          it 'creates a school experience and sends it to the API' do
            created = Bookings::Candidate.last

            expect(Bookings::Gitis::SchoolExperience).to \
              have_received(:from_placement_request).with(instance_of(Bookings::PlacementRequest), :requested)
            expect(school_experience).to \
              have_received(:write_to_gitis_contact).with(created.gitis_uuid)
          end

          it 'redirects to placement request show' do
            expect(response).to redirect_to \
              candidates_school_registrations_placement_request_path(
                school,
                uuid: uuid
              )
          end
        end

        context 'school has changed availability type' do
          let :registration_session do
            FactoryBot.build :registration_session, :with_placement_date, urn: school.urn
          end

          before do
            school.update! availability_preference_fixed: true
          end

          it_behaves_like 'a successful create'
        end

        context 'school has not changed availability type' do
          it_behaves_like 'a successful create'
        end

        context 'with an invalid session' do
          let :incomplete_registration_session do
            FactoryBot.build :registration_session,
                             urn: '333333', uuid: 'aaa', with: [:personal_information]
          end

          before do
            Candidates::Registrations::RegistrationStore.instance.store! \
              incomplete_registration_session

            get "/candidates/confirm/#{incomplete_registration_session.uuid}"
          end

          it 'redirects to the first missing step' do
            expect(response).to redirect_to \
              "/candidates/schools/#{incomplete_registration_session.urn}/registrations/contact_information/new"
          end
        end
      end
    end
  end

  context '#show' do
    before do
      get \
        "/candidates/schools/#{school.urn}/registrations/placement_request?uuid=#{uuid}"
    end

    it 'renders the show template' do
      expect(response).to render_template :show
    end
  end
end
