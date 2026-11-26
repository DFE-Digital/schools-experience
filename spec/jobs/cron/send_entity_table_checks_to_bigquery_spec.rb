require "rails_helper"

describe DfE::Analytics::EntityTableCheckJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform }

    let(:school_sync_instance) { double Object, sync: true }


    it 'executes the job successfully' do
      expect { perform }.not_to raise_error
    end
  end
end
