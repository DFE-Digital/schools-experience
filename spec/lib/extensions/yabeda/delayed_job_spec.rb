require "rails_helper"
require Rails.root.join("lib", "extensions", "yabeda", "delayed_job")

describe Extensions::Yabeda::DelayedJob do
  before { ActiveJob::Base.queue_adapter = :delayed_job }
  after { ActiveJob::Base.queue_adapter = :test }

  describe ".labelize" do
    it "does not include PII in the labels" do
      Notify::EmailJob.perform_later \
        to: "email@address.com",
        template_id: "abc-123",
        personalisation_json: { "name": "John" }.to_json

      job = Delayed::Job.first
      labels = Extensions::Yabeda::DelayedJob.labelize(job)

      expect(labels.values.join).not_to include("email@address.com")
      expect(labels.values.join).not_to include("John")
    end
  end
end
