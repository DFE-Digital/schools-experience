require 'rails_helper'

describe Candidates::Registrations::AcceptPrivacyPolicyJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers
  include_context 'fake gitis with known uuid'

  before do
    allow_any_instance_of(described_class).to \
      receive(:gitis).and_return(fake_gitis)
  end

  context '#perform' do
    before do
      allow(described_class.queue_adapter).to \
        receive(:perform_enqueued_jobs).and_return(true)
    end

    context 'on error' do
      before do
        allow(described_class.queue_adapter).to receive(:enqueue_at).and_return(true)
        allow(fake_gitis).to receive(:write) { raise "network error" }

        freeze_time

        described_class.perform_later \
          fake_gitis_uuid, Bookings::Gitis::PrivacyPolicy.default
      end

      it 'retrys the job' do
        expect(described_class.queue_adapter).to \
          have_received(:enqueue_at).with \
            an_instance_of(described_class),
            described_class::RETRYS.first.from_now.to_i
      end
    end

    context 'on success' do
      before do
        allow(fake_gitis.store).to receive(:create_entity).and_return(SecureRandom.uuid)

        freeze_time

        described_class.perform_later \
          fake_gitis_uuid, Bookings::Gitis::PrivacyPolicy.default
      end

      it "creates a CandidatePrivacyPolicy entity" do
        expect(fake_gitis.store).to have_received(:create_entity).with \
          'dfe_candidateprivacypolicies', hash_including(
            'dfe_meanofconsent' => Bookings::Gitis::PrivacyPolicy.consent,
            'dfe_timeofconsent' => Time.now.utc.iso8601,
            'dfe_Candidate@odata.bind' => "contacts(#{fake_gitis_uuid})",
            'dfe_PrivacyPolicyNumber@odata.bind' =>
              "dfe_privacypolicies(#{Bookings::Gitis::PrivacyPolicy.default})"
          )
      end
    end
  end
end
