require 'rails_helper'

describe Bookings::PlacementDate, type: :model do
  describe 'Valiation' do
    subject { described_class.new }

    context '#date' do
      it { expect(subject).to validate_presence_of(:date) }
      # FIXME should we prevent weekends?
    end

    context '#school_profile' do
      it { expect(subject).to validate_presence_of(:school_profile) }
    end

    context '#duration' do
      specify do
        expect(subject).to(
          validate_numericality_of(:duration)
            .is_greater_than_or_equal_to(1)
            .is_less_than(100)
          )
      end
      it { expect(subject).to validate_presence_of(:duration) }
    end
  end

  describe 'Relationships' do
    subject { described_class.new }
    it { expect(subject).to belong_to(:school_profile) }
  end

  describe 'Scopes' do
    let(:future_date) { create(:bookings_placement_date) }
    let(:past_date) { create(:bookings_placement_date, :in_the_past) }
    context '.past' do
      it 'should include past dates' do
        expect(described_class.past).to include(past_date)
      end

      it 'should not include future dates' do
        expect(described_class.past).not_to include(future_date)
      end
    end

    context '.future' do
      it 'should include future dates' do
        expect(described_class.future).to include(future_date)
      end

      it 'should not include past dates' do
        expect(described_class.future).not_to include(past_date)
      end
    end

    context '.in_date_order' do
      let!(:later) { create(:bookings_placement_date, date: 2.weeks.from_now) }
      let!(:early) { create(:bookings_placement_date, date: 1.week.from_now) }
      let!(:latest) { create(:bookings_placement_date, date: 3.weeks.from_now) }

      let(:correct_order) { [early, later, latest] }

      specify 'should return dates in date order when applied' do
        expect(described_class.all.to_a).not_to eql(correct_order)
        expect(described_class.all.in_date_order.to_a).to eql(correct_order)
      end
    end
  end
end
