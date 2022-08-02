require "rails_helper"

describe Cron::HeartBeatJob, type: :job do
  it "runs every minute" do
    expect(described_class.cron_expression).to eq("* * * * *")
  end

  describe "#perform" do
    let(:school_sync_instance) { double Object, sync: true }

    subject(:perform) { described_class.new.perform }

    it "increments the delayed_job_heart_beat metric" do
      expect { perform }.to increment_yabeda_counter(Yabeda.gse.delayed_job_heart_beat).by(1)
    end
  end
end
