require "rails_helper"

describe Cron::DeleteExpiredSessionsJob, type: :job do
  before { stub_const("#{described_class}::BATCH_SIZE", 2) }

  it "removes only expired registrations and browser sessions" do
    3.times do |i|
      CandidateRegistration.create!(uuid: "old-#{i}", registration_data: {}, expires_at: 1.minute.ago)
      BrowserSession.create!(session_id: "old-#{i}", session_data: "", expires_at: 1.minute.ago)
    end
    CandidateRegistration.create!(uuid: "live", registration_data: {}, expires_at: 1.minute.from_now)
    BrowserSession.create!(session_id: "live", session_data: "", expires_at: 1.minute.from_now)

    described_class.perform_now

    expect(CandidateRegistration.pluck(:uuid)).to eq %w[live]
    expect(BrowserSession.pluck(:session_id)).to eq %w[live]
  end
end
