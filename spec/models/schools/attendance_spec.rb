require 'rails_helper'

describe Schools::Attendance do
  let(:booking_1) { create(:bookings_booking, :accepted) }
  let(:booking_2) { create(:bookings_booking, :accepted) }
  let(:booking_3) { create(:bookings_booking, :accepted) }
  let(:bookings) { [booking_1, booking_2, booking_3] }
  let(:bookings_params) do
    {
      booking_1.id => true,
      booking_2.id => true,
      booking_3.id => false
    }
  end

  subject do
    described_class.new(
      bookings: bookings,
      bookings_params: bookings_params
    )
  end

  describe '#initialize' do
    specify 'should correctly assign bookings' do
      expect(subject.bookings).to match_array(bookings)
    end

    specify 'should correctly assign params' do
      expect(subject.bookings_params).to eql(
        booking_1.id => true,
        booking_2.id => true,
        booking_3.id => false
      )
    end
  end

  describe '#save' do
    context 'when booking cancelled' do
      before do
        create :cancellation, :sent, placement_request: booking_1.bookings_placement_request
        bookings.each(&:reload)
        subject.save
      end

      specify 'should not update cancelled bookings' do
        expect(booking_1.reload.attended).to be nil
      end
    end

    context 'when booking not cancelled' do
      before { subject.save }

      specify 'should correctly update bookings with param values' do
        bookings_params.each do |id, status|
          expect(Bookings::Booking.find(id).attended).to be(status)
        end
      end
    end
  end
end
