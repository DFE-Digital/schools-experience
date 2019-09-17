require 'rails_helper'

describe Candidates::Registrations::PlacementRequestJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers
  include_context 'Stubbed candidates school'

  let :registration_store do
    Candidates::Registrations::RegistrationStore.instance
  end

  let :registration_session do
    FactoryBot.build :registration_session, urn: school.urn
  end

  let :placement_request do
    FactoryBot.build :placement_request, school: school
  end

  let :school_request_confirmation_notification_link_only do
    double NotifyEmail::SchoolRequestConfirmationLinkOnly, despatch_later!: true
  end

  let :candidate_request_confirmation_notification_with_confirmation_link do
    double NotifyEmail::CandidateRequestConfirmationNoPii,
      despatch_later!: true
  end

  let :cancellation_url do
    'https://example.com/cancel-request/uuid'
  end

  let :placement_request_url do
    'https://example.com/placement-request/uuid'
  end

  let :application_preview do
    Candidates::Registrations::ApplicationPreview.new registration_session
  end

  before do
    allow(NotifyEmail::SchoolRequestConfirmationLinkOnly).to \
      receive(:new) { school_request_confirmation_notification_link_only }

    allow(NotifyEmail::CandidateRequestConfirmationNoPii).to \
      receive(:from_application_preview) { candidate_request_confirmation_notification_with_confirmation_link }

    registration_store.store! registration_session

    ActiveJob::Base.queue_adapter = :inline
  end

  context '#perform' do
    context 'no errors' do
      before do
        described_class.perform_later registration_session.uuid, cancellation_url, placement_request_url
      end

      it 'notifies the school' do
        expect(NotifyEmail::SchoolRequestConfirmationLinkOnly).to \
          have_received(:new).with \
            to: school.notification_emails,
            school_name: school.name,
            placement_request_url: placement_request_url

        expect(school_request_confirmation_notification_link_only).to \
          have_received :despatch_later!
      end

      it 'notifies the candidate' do
        expect(NotifyEmail::CandidateRequestConfirmationNoPii).to \
          have_received(:from_application_preview).with \
            registration_session.email,
            application_preview,
            cancellation_url

        expect(
          candidate_request_confirmation_notification_with_confirmation_link
        ).to have_received :despatch_later!
      end

      it 'deletes the registration session from redis' do
        expect { registration_store.retrieve! registration_session.uuid }.to \
          raise_error Candidates::Registrations::RegistrationStore::SessionNotFound
      end
    end
  end
end
