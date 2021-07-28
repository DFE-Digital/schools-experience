require "rails_helper"

describe Cron::SyncSubjectsWithGitisJob, type: :job do
  it "has a schedule of daily at 03:30" do
    expect(described_class.cron_expression).to eql("30 3 * * *")
  end

  describe "#schedule" do
    before do
      # As the test queue adapter is in use we need to 'queue' the job
      # by adding an entry to the database manually.
      Delayed::Job.new(
        handler: "job_class: #{described_class.name}",
        cron: described_class.cron_expression
      ).save!
    end

    it "destroys all #{described_class} jobs" do
      expect { described_class.schedule }.to change {
        described_class.jobs.count
      }.from(1).to(0)
    end
  end
end
