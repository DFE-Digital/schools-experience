require "rails_helper"

describe DfE::Analytics::EntityTableCheckJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform }

    it 'executes the job successfully' do
      expect { perform }.not_to raise_error
    end
  end
end
