require 'rails_helper'

describe Bookings::Reminder do
  include ActiveJob::TestHelper

  let(:time_until_booking) { '3 weeks' }
  let(:school) { create(:bookings_school, :onboarded) }
  let(:bookings) { create_list(:bookings_booking, 3, bookings_school: school, date: 3.weeks.from_now) }

  subject { Bookings::Reminder.new(time_until_booking, bookings) }

  describe '#enqueue' do
    specify 'should enqueue one job per provided booking' do
      expect(enqueued_jobs.size).to be_zero

      subject.enqueue

      expect(enqueued_jobs.size).to eql(bookings.size)
    end
  end
end
