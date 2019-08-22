require 'rails_helper'

describe Bookings::LogToGitisJob, type: :job do
  include ActiveSupport::Testing::TimeHelpers

  let(:contact) { build(:gitis_contact, :persisted) }
  let(:crm) { double Bookings::Gitis::CRM }
  before { allow(Bookings::Gitis::CRM).to receive(:new).and_return(crm) }

  context '#perform' do
    before do
      allow(described_class.queue_adapter).to \
        receive(:perform_enqueued_jobs).and_return(true)
    end

    context 'on error' do
      before do
        allow(described_class.queue_adapter).to receive(:enqueue_at).and_return(true)
        allow(crm).to receive(:log_school_experience) { raise "network error" }

        freeze_time

        described_class.perform_later \
          contact.id, '01/10/2019', 'test', '01/11/2019', '9999', 'Test School'
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
        allow(crm).to receive(:log_school_experience).and_return(contact.id)

        described_class.perform_later \
          contact.id, '01/10/2019', 'test', '01/11/2019', '9999', 'Test School'
      end

      it "logs adds an entry to Gitis" do
        expect(crm).to have_received(:log_school_experience).with \
          contact.id, '01/10/2019', 'test', '01/11/2019', '9999', 'Test School'
      end
    end
  end
end
