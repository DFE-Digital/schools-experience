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
    before { subject.save }

    specify 'should correctly update bookings with param values' do
      bookings_params.each do |id, status|
        expect(Bookings::Booking.find(id).attended).to be(status)
      end
    end
  end

  describe '#update_gitis' do
    before do
      allow(Bookings::LogToGitisJob).to receive(:perform_later).and_return('cattlee')
      subject.save
      subject.update_gitis
    end

    specify 'should correctly update bookings with param values' do
      bookings_params.each do |id, _status|
        booking = Bookings::Booking.find(id)
        expect(Bookings::LogToGitisJob).to \
          have_received(:perform_later).with \
            booking.contact_uuid,
            booking.attended ? /ATTENDED/ : /DID NOT ATTEND/
      end
    end
  end
end
