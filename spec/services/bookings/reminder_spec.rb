require 'rails_helper'

describe Bookings::Reminder do
  include ActiveJob::TestHelper

  let(:time_until_booking) { '3 weeks' }
  let(:school) { create(:bookings_school, :onboarded) }
  let(:booking) { create(:bookings_booking,  bookings_school: school, date: 3.weeks.from_now) }

  subject { Bookings::Reminder.new(booking, time_until_booking) }

  describe '#deliver' do
    specify 'should deliver one job per provided booking' do
      expect(enqueued_jobs.size).to be_zero

      subject.deliver

      expect(enqueued_jobs.size).to eql(1)
    end
  end
end
