require "rails_helper"

describe Cron::HeartBeatJob, type: :job do
  describe "#perform" do
    subject(:perform) { described_class.new.perform }

    it "increments the sidekiq_heart_beat metric" do
      expect { perform }.to increment_yabeda_counter(Yabeda.gse.sidekiq_heart_beat).by(1)
    end
  end
end
