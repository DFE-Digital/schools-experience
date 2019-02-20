require 'rails_helper'

describe Candidates::Registrations::PlacementRequestAction do
  include_context 'Stubbed candidates school'

  let :uuid do
    'some-uuid'
  end

  let :registration_session do
    FactoryBot.build :registration_session
  end

  let :registration_store do
    double Candidates::Registrations::RegistrationStore,
      retrieve!: registration_session
  end

  let :application_preview do
    double Candidates::Registrations::ApplicationPreview
  end

  let :school_request_confirmation do
    double NotifyEmail::SchoolRequestConfirmation, despatch!: true
  end

  let :candidate_request_confirmation do
    double NotifyEmail::CandidateRequestConfirmation, despatch!: true
  end

  subject { described_class.new uuid }

  context '#perform' do
    before do
      allow(Candidates::Registrations::RegistrationStore).to \
        receive(:instance) { registration_store }

      allow(Candidates::Registrations::ApplicationPreview).to \
        receive(:new) { application_preview }

      allow(NotifyEmail::SchoolRequestConfirmation).to \
        receive(:from_application_preview) { school_request_confirmation }

      allow(NotifyEmail::CandidateRequestConfirmation).to \
        receive(:from_application_preview) { candidate_request_confirmation }

      allow(Candidates::Registrations::PlacementRequest).to \
        receive :create_from_registration_session!
    end

    context 'school request notification fails' do
      before do
        allow(school_request_confirmation).to receive :despatch! do
          raise 'Oh no!'
        end
      end

      it 'doesnt persist the data to postgres' do
        expect { subject.perform! }.to raise_error RuntimeError
        expect(Candidates::Registrations::PlacementRequest).not_to \
          have_received :create_from_registration_session!
      end
    end

    context 'school request notification succeeds' do
      context 'candidate notificaton fails' do
        before do
          allow(candidate_request_confirmation).to receive :despatch! do
            raise 'Oh no!'
          end
        end

        it 'doesnt persist the data to postgres' do
          expect { subject.perform! }.to raise_error RuntimeError
          expect(Candidates::Registrations::PlacementRequest).not_to \
            have_received :create_from_registration_session!
        end
      end

      context 'candidate notification succeeds' do
        before do
          subject.perform!
        end

        it 'attempts to retreive the correct session from the store' do
          expect(registration_store).to have_received(:retrieve!).with uuid
        end

        it 'builds the application_preview correctly' do
          expect(Candidates::Registrations::ApplicationPreview).to \
            have_received(:new).with registration_session
        end

        it 'instantiates the school_request_confirmation correctly' do
          expect(NotifyEmail::SchoolRequestConfirmation).to \
            have_received(:from_application_preview)
            .with(school.contact_email, application_preview)
        end

        it 'instantiates the candidate_request_confirmation correctly' do
          expect(NotifyEmail::CandidateRequestConfirmation).to \
            have_received(:from_application_preview)
            .with(registration_session.email, application_preview)
        end

        it 'persists the registration in postgres' do
          expect(Candidates::Registrations::PlacementRequest).to \
            have_received(:create_from_registration_session!).with \
              registration_session
        end
      end
    end
  end
end
