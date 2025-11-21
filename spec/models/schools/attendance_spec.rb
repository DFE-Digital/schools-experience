require 'rails_helper'

describe Schools::Attendance do
  let(:booking_1) { create(:bookings_booking, :accepted) }
  let(:booking_2) { create(:bookings_booking, :accepted) }
  let(:booking_3) { create(:bookings_booking, :accepted) }
  let(:bookings) { [booking_1, booking_2, booking_3] }
  let(:bookings_params) do
    {
      booking_1.id.to_s => true,
      booking_2.id.to_s => true,
      booking_3.id.to_s => false
    }
  end

  let(:attendance) do
    described_class.new(
      bookings: bookings,
      bookings_params: bookings_params
    )
  end

  let :school_experience do
    instance_double(Bookings::Gitis::SchoolExperience)
  end

  let(:feedback_request_double) do
    instance_double(NotifyEmail::CandidateBookingFeedbackRequest, despatch_later!: true)
  end

  before do
    allow(NotifyEmail::CandidateBookingFeedbackRequest).to \
      receive(:from_booking) { feedback_request_double }
  end

  subject { attendance }

  describe '#initialize' do
    specify 'should correctly assign bookings' do
      expect(subject.bookings).to match_array(bookings)
    end

    specify 'should correctly assign params' do
      expect(subject.bookings_params).to eql(
        booking_1.id.to_s => true,
        booking_2.id.to_s => true,
        booking_3.id.to_s => false
      )
    end
  end

  describe '#save' do
    context 'when booking cancelled' do
      before do
        create :cancellation, :sent, placement_request: booking_1.bookings_placement_request
        bookings.each(&:reload)
      end

      subject! { attendance.save }

      specify 'should not update cancelled bookings' do
        expect(booking_1.reload.attended).to be nil
      end

      specify 'sends feedback emails for attended (and not cancelled) bookings' do
        expect(NotifyEmail::CandidateBookingFeedbackRequest).to \
          have_received(:from_booking).with(booking_2).once
      end

      specify 'does not send feedback emails for unattended (or cancelled) bookings' do
        # Cancelled
        expect(NotifyEmail::CandidateBookingFeedbackRequest).not_to \
          have_received(:from_booking).with(booking_1)
        # Unattended
        expect(NotifyEmail::CandidateBookingFeedbackRequest).not_to \
          have_received(:from_booking).with(booking_3)
      end

      specify 'save should return false' do
        is_expected.to be false
      end

      specify 'attendance should have 1 error' do
        expect(attendance.errors.messages.length).to eql 1
        expect(attendance.errors.messages[:bookings_params].length).to eql 1
        expect(attendance.errors.messages[:bookings_params].first).to \
          match(/unable to set attendance/i)
      end

      specify 'attendance.updated_bookings' do
        expect(attendance.updated_bookings).to match_array \
          [booking_2.id, booking_3.id]
      end
    end

    context 'when booking not cancelled' do
      subject! { attendance.save }

      specify 'should correctly update bookings with param values' do
        bookings_params.each do |id, status|
          expect(Bookings::Booking.find(id).attended).to be(status)
        end
      end

      specify 'save should return true' do
        is_expected.to be true
      end

      specify 'attendance.updated_bookings' do
        expect(attendance.updated_bookings).to match_array bookings.pluck(:id)
      end
    end
  end

  describe '#update_gitis' do
    before do
      allow(Bookings::Gitis::SchoolExperience).to \
        receive(:from_booking) { school_experience }

      allow(school_experience).to \
        receive(:write_to_gitis_contact)

      subject.save
      subject.update_gitis
    end

    specify 'should correctly update bookings with param values' do
      bookings_params.each do |id, _status|
        booking = Bookings::Booking.find(id)

        expect(Bookings::Gitis::SchoolExperience).to \
          have_received(:from_booking).with(instance_of(Bookings::Booking), :completed).exactly(2).times
        expect(Bookings::Gitis::SchoolExperience).to \
          have_received(:from_booking).with(instance_of(Bookings::Booking), :did_not_attend).exactly(1).time
        expect(school_experience).to \
          have_received(:write_to_gitis_contact).with(booking.contact_uuid)
      end
    end
  end
end
