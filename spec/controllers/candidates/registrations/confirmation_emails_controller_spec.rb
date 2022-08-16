require 'rails_helper'

describe Candidates::Registrations::ConfirmationEmailsController, type: :request do
  include_context 'Stubbed candidates school'
  include_context 'Stubbed current_registration'

  let :registration_session do
    FactoryBot.build :registration_session, urn: school.urn,
                                            with: %i[
                                              personal_information
                                              contact_information
                                              education
                                              teaching_preference
                                              placement_preference
                                              availability_preference
                                              background_check
                                              subject_and_date_information
                                            ]
  end

  let :registration_store do
    Candidates::Registrations::RegistrationStore.instance
  end

  before do
    allow(Candidates::Registrations::SendEmailConfirmationJob).to \
      receive(:perform_later)
  end

  context '#create' do
    context 'skipped step' do
      before { registration_store.send :delete, 'some-uuid' } # ensure key not left lying around

      let :registration_session do
        FactoryBot.build :registration_session, with: []
      end

      before do
        post candidates_school_registrations_confirmation_email_path(school)
      end

      it "doesn't store the session" do
        expect {
          registration_store.retrieve! registration_session.uuid
        }.to raise_error \
          Candidates::Registrations::RegistrationStore::SessionNotFound
      end

      it "doesn't enqueues the confirmation email job" do
        expect(Candidates::Registrations::SendEmailConfirmationJob).not_to \
          have_received(:perform_later).with \
            registration_session.uuid, 'www.example.com'
      end

      it "redirects to the first missing step" do
        expect(response).to redirect_to \
          new_candidates_school_registrations_personal_information_path school
      end
    end

    context 'no skipped steps' do
      before do
        post candidates_school_registrations_confirmation_email_path(school)
      end

      it 'marks the session as pending' do
        expect(registration_session).to be_pending_email_confirmation
      end

      it 'stores the session' do
        expect(registration_store.retrieve!(registration_session.uuid)).to \
          eq registration_session
      end

      it 'enqueues the confirmation email job' do
        expect(Candidates::Registrations::SendEmailConfirmationJob).to \
          have_received(:perform_later).with \
            registration_session.uuid, 'www.example.com'
      end

      it 'redirects to the check your email page' do
        expect(response).to redirect_to \
          candidates_school_registrations_confirmation_email_path school
      end
    end

    context 'no skipped steps and already signed in' do
      let(:candidate) { create(:candidate, :confirmed) }
      let(:contact) do
        api = GetIntoTeachingApiClient::SchoolsExperienceApi.new
        api.get_schools_experience_sign_up(candidate.gitis_uuid)
      end
      let(:contact_attributes) { contact.to_hash }

      before do
        allow_any_instance_of(ActionDispatch::Request::Session).to \
          receive(:[]).with(:gitis_contact).and_return(contact_attributes)

        post candidates_school_registrations_confirmation_email_path(school)
      end

      it 'stores the session' do
        expect(registration_store.retrieve!(registration_session.uuid)).to \
          eq registration_session
      end

      it 'does not mark the session as pending email confirmation' do
        expect(registration_session).not_to be_pending_email_confirmation
      end

      it 'wont enqueue a confirmation email job' do
        expect(Candidates::Registrations::SendEmailConfirmationJob).not_to \
          have_received(:perform_later).with \
            registration_session.uuid, 'www.example.com'
      end

      it 'redirects to the placement_request page' do
        expect(response).to redirect_to \
          candidates_confirm_path registration_session.uuid
      end
    end
  end

  context '#show' do
    before do
      get candidates_school_registrations_confirmation_email_path school
    end

    it 'assigns email for the view' do
      expect(assigns(:email)).to eq 'test@example.com'
    end

    it 'assigns school name for the view' do
      expect(assigns(:school_name)).to eq 'Test School'
    end

    it 'assigns retry path for the view' do
      expect(assigns(:resend_link)).to eq \
        '/candidates/schools/11048/registrations/resend_confirmation_email'
    end
  end
end
