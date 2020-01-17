require 'rails_helper'

describe Schools::PlacementDates::DateLimitForm, type: :model do
  let(:placement_date) { create :bookings_placement_date, :capped }

  describe '.new_from_date' do
    subject { described_class.new_from_date placement_date }

    it "will retrieve attributes from placement_date" do
      is_expected.to have_attributes \
        max_bookings_count: placement_date.max_bookings_count
    end
  end

  describe '#validations' do
    subject { described_class.new }
    it { is_expected.to allow_value(1).for(:max_bookings_count) }
    it { is_expected.to allow_value(10).for(:max_bookings_count) }
    it { is_expected.not_to allow_value(0).for(:max_bookings_count) }
    it { is_expected.not_to allow_value(0.5).for(:max_bookings_count) }
    it { is_expected.not_to allow_value(-1).for(:max_bookings_count) }
    it { is_expected.not_to allow_value(nil).for(:max_bookings_count) }
    it { is_expected.not_to allow_value('').for(:max_bookings_count) }
  end

  describe '#save' do
    context 'when invalid form' do
      subject { described_class.new max_bookings_count: 0 }
      it { expect(subject.save(placement_date)).to be false }
    end

    context 'when valid form' do
      subject { described_class.new max_bookings_count: 5 }

      context 'when valid placement_date' do
        it { expect(subject.save(placement_date)).to be true }
      end

      context 'when invalid placement_date' do
        before { allow(placement_date).to receive(:valid?).and_return(false) }

        it "will raise an error and not sve" do
          expect { subject.save(placement_date) }.to raise_exception \
            ActiveRecord::RecordInvalid

          expect(placement_date.reload).not_to \
            have_attributes max_bookings_count: 5
        end
      end
    end
  end
end
