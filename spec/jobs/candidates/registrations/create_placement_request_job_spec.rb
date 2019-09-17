require 'rails_helper'

describe Candidates::Registrations::CreatePlacementRequestJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers
  include_context 'fake gitis'

  before do
    allow_any_instance_of(described_class).to \
      receive(:gitis).and_return(fake_gitis)
  end

  let(:token) { SecureRandom.urlsafe_base64 }
  let(:analytics) { SecureRandom.uuid }

  context '#perform' do
    let!(:create_request) do
      double Candidates::Registrations::CreatePlacementRequest, create!: true
    end

    before do
      allow(described_class.queue_adapter).to \
        receive(:perform_enqueued_jobs).and_return(true)
    end

    context 'on success' do
      before do
        allow(Candidates::Registrations::CreatePlacementRequest).to \
          receive(:new).and_return(create_request)
      end

      subject! do
        described_class.perform_later token, nil, 'test.com', analytics
      end

      it "will call Service Object with correct params" do
        expect(Candidates::Registrations::CreatePlacementRequest).to \
          have_received(:new).with \
            fake_gitis, token, nil, 'test.com', analytics
      end
    end

    context 'on error' do
      before do
        allow(described_class.queue_adapter).to \
          receive(:enqueue_at).and_return(true)

        freeze_time
      end

      subject! do
        described_class.perform_later token, nil, 'test.com', analytics
      end

      it 'retrys the job' do
        expect(described_class.queue_adapter).to \
          have_received(:enqueue_at).with \
            an_instance_of(described_class),
            3.seconds.from_now.to_i
      end
    end
  end
end
