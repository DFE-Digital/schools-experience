require 'rails_helper'

describe Bookings::PlacementDate, type: :model do
  describe 'Columns' do
    it { is_expected.to have_db_column(:bookings_school_id).of_type(:integer) }
    it { is_expected.to have_db_column(:date).of_type(:date) }
    it { is_expected.to have_db_column(:duration).of_type(:integer) }
    it { is_expected.to have_db_column(:active).of_type(:boolean) }
  end

  describe 'Valiation' do
    subject { described_class.new }

    context '#date' do
      it { expect(subject).to validate_presence_of(:date) }

      context 'new placement dates must be in the future' do
        specify 'should allow future dates' do
          [Date.tomorrow, 3.days.from_now, 3.weeks.from_now, 3.years.from_now].each do |d|
            expect(subject).to allow_value(d).for(:date)
          end
        end

        specify 'new placement dates should not allow historic dates' do
          [Date.yesterday, 3.days.ago, 3.weeks.ago, 3.years.ago].each do |d|
            expect(subject).not_to allow_value(d).for(:date)
          end
        end

        context 'error messages' do
          let(:message) { 'Date must be in the future' }
          let(:invalid_pd) { create(:bookings_placement_date, date: 3.weeks.ago) }

          specify 'should show a suitable error message' do
            expect { invalid_pd }.to(
              raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Date must be in the future')
            )
          end
        end

        context 'updating expired placement dates' do
          let(:expired_pd) { create(:bookings_placement_date, :active, :in_the_past) }

          specify 'should allow updates' do
            expect(expired_pd.update(active: false)).to be(true)
            expect(expired_pd).to_not be_active
          end
        end
      end
    end

    context '#bookings_school' do
      it { expect(subject).to validate_presence_of(:bookings_school) }
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
    it { expect(subject).to belong_to(:bookings_school) }
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

    context '.active' do
      let!(:active) { create(:bookings_placement_date, active: true) }
      let!(:inactive) { create(:bookings_placement_date, active: false) }

      specify 'should return active placement dates' do
        expect(described_class.active).to include(active)
      end

      specify 'should not return inactive placement dates' do
        expect(described_class.active).not_to include(inactive)
      end
    end

    context '.inactive' do
      let!(:active) { create(:bookings_placement_date, active: true) }
      let!(:inactive) { create(:bookings_placement_date, active: false) }

      specify 'should return inactive placement dates' do
        expect(described_class.inactive).to include(inactive)
      end

      specify 'should not return active placement dates' do
        expect(described_class.inactive).not_to include(active)
      end
    end

    context '.available' do
      after { described_class.available }
      specify 'should combine the future, active and in_date_order scopes' do
        expect(described_class).to receive_message_chain(:active, :future, :in_date_order)
      end
    end
  end
end
