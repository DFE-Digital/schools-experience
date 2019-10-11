require 'rails_helper'

describe Schools::BookingsHelper, type: 'helper' do
  describe '#attendance_status' do
    subject { attendance_status booking }

    context 'for attended' do
      let(:booking) { create(:bookings_booking, :attended) }

      it do
        is_expected.to \
          have_css('strong.govuk-tag.govuk-tag--available', text: 'YES')
      end
    end

    context 'for unattended' do
      let(:booking) { create(:bookings_booking, :unattended) }

      it do
        is_expected.to \
          have_css('strong.govuk-tag.govuk-tag--unavailable', text: 'NO')
      end
    end

    context 'for cancelled' do
      let(:booking) { create(:bookings_booking, :cancelled_by_school) }

      it do
        is_expected.to \
          have_css('strong.govuk-tag.govuk-tag--unavailable', text: 'CANCELLED')
      end
    end

    context 'for unknown' do
      let(:booking) { create(:bookings_booking, :accepted) }
      it do
        is_expected.to \
          have_css('strong.govuk-tag.govuk-tag--default', text: 'NOT SET')
      end
    end
  end
end
