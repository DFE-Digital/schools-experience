require 'rails_helper'

describe Schools::Attendance do
  let(:booking_1) { create(:bookings_booking) }
  let(:booking_2) { create(:bookings_booking) }
  let(:booking_3) { create(:bookings_booking) }
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
    before { subject.save }

    specify 'should correctly update bookings with param values' do
      bookings_params.each do |id, status|
        expect(Bookings::Booking.find(id).attended).to be(status)
      end
    end
  end
end
