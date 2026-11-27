require 'rails_helper'

describe Schools::BookingsHelper, type: 'helper' do
  describe '#attendance_status' do
    subject { attendance_status booking }

    context 'with attended' do
      let(:booking) { create(:bookings_booking, :attended) }

      it do
        expect(subject).to \
          have_css('strong.govuk-tag', text: 'Yes')
      end
    end

    context 'with unattended' do
      let(:booking) { create(:bookings_booking, :unattended) }

      it do
        expect(subject).to \
          have_css('strong.govuk-tag.govuk-tag--grey', text: 'No')
      end
    end

    context 'with cancelled' do
      let(:booking) { create(:bookings_booking, :cancelled_by_school) }

      it do
        expect(subject).to \
          have_css('strong.govuk-tag.govuk-tag--red', text: 'Cancelled')
      end
    end

    context 'with unknown' do
      let(:booking) { create(:bookings_booking, :accepted) }

      it do
        expect(subject).to \
          have_css('strong.govuk-tag.govuk-tag--teal', text: 'Not set')
      end
    end
  end
end
