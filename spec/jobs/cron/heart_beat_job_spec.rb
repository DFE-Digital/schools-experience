require "rails_helper"

describe Cron::HeartBeatJob, type: :job do
  describe "#perform" do
    let(:school_sync_instance) { double Object, sync: true }

    subject(:perform) { described_class.new.perform }

    it "increments the sidekiq_heart_beat metric" do
      expect { perform }.to increment_yabeda_counter(Yabeda.gse.sidekiq_heart_beat).by(1)
    end
  end
end
