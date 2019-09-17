require 'rails_helper'

describe Candidates::Registrations::CreatePlacementRequest do
  include_context 'Stubbed candidates school'

  let(:host) { 'example.com' }

  let :school do
    create :bookings_school, \
      name: 'Test School',
      contact_email: 'test@test.com',
      urn: school_urn
  end

  let :registration_store do
    Candidates::Registrations::RegistrationStore.instance
  end

  let :registration_session do
    FactoryBot.build :registration_session, urn: school.urn
  end

  let :school_request_confirmation_notification_link_only do
    double NotifyEmail::SchoolRequestConfirmationLinkOnly, despatch_later!: true
  end

  let :candidate_request_confirmation_notification_with_confirmation_link do
    double NotifyEmail::CandidateRequestConfirmationNoPii,
      despatch_later!: true
  end

  let :cancellation_url do
    %r{\Ahttps://example.com/candidates/cancel/\w{24}\z}
  end

  let :placement_request_url do
    %r{\Ahttps://example.com/schools/placement_requests/\d+\z}
  end

  let :application_preview do
    Candidates::Registrations::ApplicationPreview.new registration_session
  end

  describe '#create!' do
    shared_examples 'create placement request' do
      it "creates placment request" do
        expect(Bookings::PlacementRequest.count).to \
          eq @placement_request_count + 1
        expect(Bookings::PlacementRequest.last.school.urn).to \
          eq school_urn
      end
    end

    shared_examples 'send emails' do
      it "notifies the school" do
        expect(NotifyEmail::SchoolRequestConfirmationLinkOnly).to \
          have_received(:new).with \
            to: school.notification_emails,
            school_name: school.name,
            placement_request_url: placement_request_url

        expect(school_request_confirmation_notification_link_only).to \
          have_received :despatch_later!
      end

      it "notifies the candidate" do
        expect(NotifyEmail::CandidateRequestConfirmationNoPii).to \
          have_received(:from_application_preview).with \
            registration_session.email,
            application_preview,
            cancellation_url

        expect(
          candidate_request_confirmation_notification_with_confirmation_link
        ).to have_received :despatch_later!
      end
    end

    shared_examples 'remove from registration session' do
      it 'deletes the registration session from redis' do
        expect { registration_store.retrieve! registration_session.uuid }.to \
          raise_error Candidates::Registrations::RegistrationStore::SessionNotFound
      end
    end

    shared_examples 'schedule gitis jobs' do
      it "schedules accepting the privacy policy" do
        expect(Candidates::Registrations::AcceptPrivacyPolicyJob).to \
          have_received(:perform_later).with \
            contactid,
            Bookings::Gitis::PrivacyPolicy.default
      end

      it 'schedules the log to gitis' do
        expect(Bookings::LogToGitisJob).to \
          have_received(:perform_later).with \
            contactid,
            %r{#{Date.today.to_formatted_s(:gitis)} REQUEST}
      end
    end

    before do
      @placement_request_count = Bookings::PlacementRequest.count

      allow(NotifyEmail::SchoolRequestConfirmationLinkOnly).to \
        receive(:new) { school_request_confirmation_notification_link_only }

      allow(NotifyEmail::CandidateRequestConfirmationNoPii).to \
        receive(:from_application_preview) { candidate_request_confirmation_notification_with_confirmation_link }

      allow(Bookings::LogToGitisJob).to \
        receive(:perform_later).and_return(true)

      allow(Candidates::Registrations::AcceptPrivacyPolicyJob).to \
        receive(:perform_later).and_return(true)

      registration_store.store! registration_session
    end

    subject { described_class.new(uuid, contactid, host, SecureRandom.uuid) }

    context 'with known registration uuid' do
      let(:uuid) { registration_session.uuid }
      let(:contactid) { nil }

      xcontext 'but without gitis contact' do
        before { subject.create! }
        include_examples 'create placement request'
        include_examples 'send emails'
        include_examples 'remove from registration session'
        include_examples 'schedule gitis jobs'
      end

      context 'and known gitis contact' do
        let(:contact) { build(:gitis_contact, :persisted) }
        let(:contactid) { contact.id }

        before do
          create :candidate, gitis_uuid: contactid
          subject.create!
        end

        include_examples 'create placement request'
        include_examples 'send emails'
        include_examples 'remove from registration session'
        include_examples 'schedule gitis jobs'
      end

      context 'but unknown gitis contact' do
        it 'will raise an exception'
      end
    end

    context 'with unknown registration uuid' do
      let(:uuid) { SecureRandom.urlsafe_base64 }
      let(:contactid) { nil }

      it 'will raise an exception' do
        expect {
          subject.create!
        }.to raise_exception(Candidates::Registrations::RegistrationStore::SessionNotFound)
      end
    end
  end
end
