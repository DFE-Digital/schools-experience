require 'rails_helper'

describe Schools::BookingsHelper, type: 'helper' do
  describe '#attendance_status' do
    subject { attendance_status booking }

    context 'for attended' do
      let(:booking) { create(:bookings_booking, :attended) }

      it do
        is_expected.to \
          have_css('strong.govuk-tag', text: 'Yes')
      end
    end

    context 'for unattended' do
      let(:booking) { create(:bookings_booking, :unattended) }

      it do
        is_expected.to \
          have_css('strong.govuk-tag.govuk-tag--grey', text: 'No')
      end
    end

    context 'for cancelled' do
      let(:booking) { create(:bookings_booking, :cancelled_by_school) }

      it do
        is_expected.to \
          have_css('strong.govuk-tag.govuk-tag--red', text: 'Cancelled')
      end
    end

    context 'for unknown' do
      let(:booking) { create(:bookings_booking, :accepted) }
      it do
        is_expected.to \
          have_css('strong.govuk-tag.govuk-tag--light-blue', text: 'Not set')
      end
    end
  end
end
