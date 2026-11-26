require 'rails_helper'

describe Bookings::Reminder, type: :request do
  include ActiveJob::TestHelper

  subject { described_class.new(booking, time_until_booking, time_until_booking_descriptive) }

  let(:time_until_booking) { '3 weeks' }
  let(:time_until_booking_descriptive) { 'in 3 weeks' }
  let(:school) { create(:bookings_school, :onboarded) }
  let(:booking) { create(:bookings_booking, :accepted, bookings_school: school, date: 3.weeks.from_now) }
  let(:schools_experience_api) { instance_double(GetIntoTeachingApiClient::SchoolsExperienceApi) }
  let(:gitis_sign_up) { build(:api_schools_experience_sign_up_with_name) }

  before do
    allow(Feature).to receive(:enabled?).with(:sms).and_return(true)
    allow(GetIntoTeachingApiClient::SchoolsExperienceApi).to receive(:new).and_return(schools_experience_api)
    allow(schools_experience_api).to receive(:get_schools_experience_sign_up).and_return(gitis_sign_up)
  end

  describe '#deliver' do
    it "queues an email and sms per provided booking" do
      allow(schools_experience_api).to receive(:get_schools_experience_sign_up)
        .with(booking.contact_uuid).and_return(gitis_sign_up)

      expect { subject.deliver }.to change(enqueued_jobs, :size).by(2)
      expect(schools_experience_api).to have_received(:get_schools_experience_sign_up)
        .with(booking.contact_uuid)
    end

    context "when it's an in school experience" do
      let(:notification) { instance_double(NotifyEmail::CandidateBookingReminder) }

      before do
        allow(NotifyEmail::CandidateBookingReminder).to receive(:from_booking).and_return(notification)
        allow(notification).to receive(:despatch_later!)
      end

      it "despatches the in school reminder email" do
        subject.deliver

        expect(notification).to have_received(:despatch_later!)
      end
    end

    context "when it's a virtual experience" do
      let(:booking) { create(:bookings_booking, :accepted, :virtual_experience, bookings_school: school, date: 3.weeks.from_now) }
      let(:notification) { instance_double(NotifyEmail::CandidateVirtualExperienceBookingReminder) }

      before do
        allow(NotifyEmail::CandidateVirtualExperienceBookingReminder).to receive(:from_booking)
          .and_return(notification)
        allow(notification).to receive(:despatch_later!)
      end

      it "despatches the virtual reminder email" do
        subject.deliver

        expect(notification).to have_received(:despatch_later!)
      end
    end
  end
end
