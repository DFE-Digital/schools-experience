require 'rails_helper'

describe Candidates::Registrations::CreatePlacementRequest do
  include_context 'Stubbed candidates school'

  let(:host) { 'example.com' }

  let :school do
    create :bookings_school, :with_subjects, \
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

  let :placement_request do
    FactoryBot.create :placement_request, school: school
  end

  let :school_request_confirmation_notification_link_only do
    double NotifyEmail::SchoolRequestConfirmationLinkOnly, despatch_later!: true
  end

  let :candidate_request_confirmation_notification_with_confirmation_link do
    double NotifyEmail::CandidateRequestConfirmationWithConfirmationLink,
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
    shared_examples 'sends emails' do
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
        expect(NotifyEmail::CandidateRequestConfirmationWithConfirmationLink).to \
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
      allow(NotifyEmail::SchoolRequestConfirmationLinkOnly).to \
        receive(:new) { school_request_confirmation_notification_link_only }

      allow(NotifyEmail::CandidateRequestConfirmationWithConfirmationLink).to \
        receive(:from_application_preview) { candidate_request_confirmation_notification_with_confirmation_link }

      allow(Bookings::LogToGitisJob).to \
        receive(:perform_later).and_return(true)

      allow(Candidates::Registrations::AcceptPrivacyPolicyJob).to \
        receive(:perform_later).and_return(true)

      registration_store.store! registration_session
    end

    subject { described_class.new(placement_request.id, uuid, contactid, host) }

    context 'with known uuid' do
      let(:uuid) { registration_session.uuid }
      let(:contactid) { nil }

      context 'without gitis contact' do
        before { subject.create! }
        include_examples 'sends emails'
        include_examples 'remove from registration session'
        include_examples 'schedule gitis jobs'
      end

      context 'with known gitis contact' do
        let(:contact) { build(:gitis_contact) }
        let(:contactid) { contact.id }
        before { subject.create! }

        include_examples 'sends emails'
        include_examples 'remove from registration session'
        include_examples 'schedule gitis jobs'
      end

      context 'with unknown gitis contact' do
        it 'will raise an exception'
      end
    end

    context 'with unknown uuid' do
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
