require 'rails_helper'

describe Bookings::Reminder do
  include ActiveJob::TestHelper

  let(:time_until_booking) { '3 weeks' }
  let(:school) { create(:bookings_school, :onboarded) }
  let(:booking) { create(:bookings_booking,  bookings_school: school, date: 3.weeks.from_now) }

  subject { Bookings::Reminder.new(booking, time_until_booking) }

  describe '#deliver' do
    it "delivers one job per provided booking" do
      sign_up = build(:api_schools_experience_sign_up)

      expect_any_instance_of(GetIntoTeachingApiClient::SchoolsExperienceApi).to \
        receive(:get_schools_experience_sign_up).with(booking.contact_uuid) { sign_up }

      expect { subject.deliver }.to change { enqueued_jobs.size }.by(1)
    end
  end
end
