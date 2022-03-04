require 'rails_helper'

describe Schools::PlacementDates::RecurrencesSelection, type: :model do
  let(:now) { Time.zone.now }

  context 'validations' do
    context '#start_at' do
      it { expect(subject).to validate_presence_of(:start_at) }
    end

    context '#end_at' do
      it { expect(subject).to validate_presence_of(:end_at) }

      it "cannot be the same day as start_at" do
        subject.start_at = now
        is_expected.not_to allow_value(now).for :end_at
      end

      it "cannot be earlier than start_at" do
        subject.start_at = now
        is_expected.not_to allow_value(now - 1.day).for :end_at
      end

      it "can be later than start_at" do
        subject.start_at = now
        is_expected.to allow_value(now + 1.day).for :end_at
      end
    end

    context '#recurrence_period' do
      it { expect(subject).to validate_presence_of(:recurrence_period) }
    end
  end

  context '.new_from_date' do
    subject { described_class.new_from_date placement_date }

    let(:placement_date) { create :bookings_placement_date, published_at: DateTime.now }

    it 'returns a new recurrences_selection with start_at' do
      expect(subject.start_at).to eq placement_date.date
    end
  end

  context '#recurring_dates' do
    context "when daily" do
      let(:next_monday) { Date.today.next_occurring(:monday) }
      let(:monday_after_next) { next_monday.next_occurring(:monday) }
      let(:attributes) do
        {
          start_at: next_monday,
          end_at: monday_after_next.next_occurring(:tuesday),
          recurrence_period: "daily"
        }
      end

      subject { described_class.new(attributes).recurring_dates }

      it 'returns a correct array of dates (skipping weekends)' do
        expect(subject).to eq [
          next_monday,
          next_monday.next_occurring(:tuesday),
          next_monday.next_occurring(:wednesday),
          next_monday.next_occurring(:thursday),
          next_monday.next_occurring(:friday),
          monday_after_next,
          monday_after_next.next_occurring(:tuesday)
        ]
      end
    end

    context "when weekly" do
      let(:next_monday) { Date.today.next_occurring(:monday) }
      let(:attributes) do
        {
          start_at: next_monday,
          end_at: (next_monday + 3.weeks).next_occurring(:friday),
          recurrence_period: "weekly"
        }
      end

      subject { described_class.new(attributes).recurring_dates }

      it 'returns a correct array of dates' do
        expect(subject).to eq [
          next_monday,
          next_monday + 1.week,
          next_monday + 2.weeks,
          next_monday + 3.weeks
        ]
      end
    end

    context "when fortnightly" do
      let(:next_monday) { Date.today.next_occurring(:monday) }
      let(:attributes) do
        {
          start_at: next_monday,
          end_at: (next_monday + 3.weeks).next_occurring(:friday),
          recurrence_period: "fortnightly"
        }
      end

      subject { described_class.new(attributes).recurring_dates }

      it 'returns a correct array of dates' do
        expect(subject).to eq [
          next_monday,
          next_monday + 2.weeks
        ]
      end
    end
  end
end
