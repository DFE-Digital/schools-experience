require 'rails_helper'

describe Schools::Attendance do
  subject { attendance }

  let(:first_booking) { create(:bookings_booking, :accepted) }
  let(:second_booking) { create(:bookings_booking, :accepted) }
  let(:third_booking) { create(:bookings_booking, :accepted) }
  let(:bookings) { [first_booking, second_booking, third_booking] }
  let(:bookings_params) do
    {
      first_booking.id.to_s => true,
      second_booking.id.to_s => true,
      third_booking.id.to_s => false
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


  describe '#initialize' do
    specify 'should correctly assign bookings' do
      expect(subject.bookings).to match_array(bookings)
    end

    specify 'should correctly assign params' do
      expect(subject.bookings_params).to eql(
        first_booking.id.to_s => true,
        second_booking.id.to_s => true,
        third_booking.id.to_s => false
      )
    end
  end

  describe '#save' do
    context 'when booking cancelled' do
      before do
        create :cancellation, :sent, placement_request: first_booking.bookings_placement_request
        bookings.each(&:reload)
      end

      subject! { attendance.save } # rubocop:disable RSpec/LeadingSubject -- Save must run after cancellation setup.

      specify 'should not update cancelled bookings' do
        expect(first_booking.reload.attended).to be_nil
      end

      specify 'sends feedback emails for attended (and not cancelled) bookings' do
        expect(NotifyEmail::CandidateBookingFeedbackRequest).to \
          have_received(:from_booking).with(second_booking).once
      end

      specify 'does not send feedback emails for unattended (or cancelled) bookings' do
        # Cancelled
        expect(NotifyEmail::CandidateBookingFeedbackRequest).not_to \
          have_received(:from_booking).with(first_booking)
        # Unattended
        expect(NotifyEmail::CandidateBookingFeedbackRequest).not_to \
          have_received(:from_booking).with(third_booking)
      end

      specify 'save should return false' do
        expect(subject).to be false
      end

      specify 'attendance should have 1 error' do
        expect(attendance.errors.messages.length).to be 1
        expect(attendance.errors.messages[:bookings_params].length).to be 1
        expect(attendance.errors.messages[:bookings_params].first).to \
          match(/unable to set attendance/i)
      end

      specify 'attendance.updated_bookings' do
        expect(attendance.updated_bookings).to contain_exactly(second_booking.id, third_booking.id)
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
        expect(subject).to be true
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
      bookings_params.each_key do |id|
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
