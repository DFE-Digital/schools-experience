require "rails_helper"

describe DfE::Analytics::EntityTableCheckJob, type: :job do
  describe "#perform" do
    let(:school_sync_instance) { double Object, sync: true }

    subject(:perform) { described_class.new.perform }

    it 'executes the job successfully' do
      expect { perform }.not_to raise_error
    end
  end
end
