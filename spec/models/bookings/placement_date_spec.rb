require 'rails_helper'

describe Bookings::PlacementDate, type: :model do
  let! :school do
    create :bookings_school, :with_subjects, subject_count: 3
  end

  describe 'Columns' do
    it { is_expected.to have_db_column(:bookings_school_id).of_type(:integer) }
    it { is_expected.to have_db_column(:date).of_type(:date) }
    it { is_expected.to have_db_column(:duration).of_type(:integer) }
    it { is_expected.to have_db_column(:active).of_type(:boolean) }
    it { is_expected.to have_db_column(:virtual).of_type(:boolean) }
    it { is_expected.to have_db_column(:max_bookings_count).of_type(:integer) }
    it { is_expected.to have_db_column(:published_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:subject_specific).of_type(:boolean).with_options(default: false, null: false) }
    it { is_expected.to have_db_column(:supports_subjects).of_type(:boolean) }
  end

  describe 'Validation' do
    subject { described_class.new }

    context '#date' do
      it { expect(subject).to validate_presence_of(:date) }

      context 'new placement dates must not be in the past' do
        specify 'should allow future dates' do
          [Time.zone.tomorrow, 3.days.from_now, 3.weeks.from_now, 3.months.from_now].each do |d|
            expect(subject).to allow_value(d).for(:date)
          end
        end

        specify 'new placement dates should not allow historic dates' do
          [Time.zone.yesterday, 3.days.ago, 3.weeks.ago, 3.years.ago].each do |d|
            expect(subject).not_to allow_value(d).for(:date)
          end
        end

        specify 'new placement dates should not allow today' do
          expect(subject).not_to allow_value(Time.zone.today).for(:date)
        end

        context 'error messages' do
          let(:message) { 'Date must be in the future' }
          let(:invalid_pd) { build(:bookings_placement_date, date: 3.weeks.ago) }

          before { invalid_pd.valid? }
          subject { invalid_pd.errors.full_messages }

          specify 'should show a suitable error message' do
            is_expected.to include(message)
          end
        end

        context 'updating expired placement dates' do
          let(:expired_pd) { build(:bookings_placement_date, :active, :in_the_past) }
          before { expired_pd.save(validate: false) }

          specify 'should allow updates' do
            expect(expired_pd.update(active: false)).to be(true)
            expect(expired_pd).to_not be_active
          end
        end

        context 'not too far in the future' do
          specify 'should not allow dates more than 2 years in the future' do
            expect(subject).not_to allow_value((2.years + 1.day).from_now).for(:date)
            expect(subject).to allow_value((2.years - 1.day).from_now).for(:date)
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

    context '#virtual' do
      it { is_expected.to allow_values(true).for :virtual }
      it { is_expected.to allow_values(false).for :virtual }
      it { is_expected.not_to allow_values(nil).for :virtual }
    end

    context '#max_bookings_count' do
      before { subject.published_at = Time.zone.today }
      it do
        is_expected.to \
          validate_numericality_of(:max_bookings_count).is_greater_than(0).allow_nil
      end
    end

    context '#subjects' do
      context 'published' do
        before { subject.published_at = Time.zone.today }

        context 'when not subject_specific?' do
          before { subject.subject_specific = false }

          it { is_expected.to validate_absence_of(:subjects) }
        end

        context 'when subject_specific?' do
          before { subject.subject_specific = true }

          it { is_expected.to validate_presence_of(:subjects) }
        end
      end

      context 'unpublished' do
        before { subject.published_at = nil }

        context 'when not subject_specific?' do
          before { subject.subject_specific = false }

          it { is_expected.not_to validate_absence_of(:subjects) }
        end

        context 'when subject_specific?' do
          before { subject.subject_specific = true }

          it { is_expected.not_to validate_presence_of(:subjects) }
        end
      end
    end
  end

  describe 'Relationships' do
    it { is_expected.to belong_to(:bookings_school) }
    it { is_expected.to have_many(:placement_requests) }
  end

  describe 'Scopes' do
    let(:future_date) { create(:bookings_placement_date) }
    let(:past_date) { create(:bookings_placement_date, :in_the_past) }
    let(:today_date) { create(:bookings_placement_date, :in_the_past, date: Time.zone.today) }

    context '.bookable_date' do
      subject { described_class.bookable_date }

      it 'should include future dates' do
        is_expected.to include(future_date)
      end

      it 'should not include past dates' do
        is_expected.not_to include(past_date)
      end

      it 'should include dates on today' do
        is_expected.not_to include(today_date)
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
      specify 'should combine the future, active, published, and in_date_order scopes' do
        expect(described_class).to receive_message_chain(:published, :active, :bookable_date, :in_date_order)
      end
    end

    context '.published' do
      let!(:published) { create :bookings_placement_date }
      let!(:un_publised) { create :bookings_placement_date, published_at: nil }

      specify 'should return only the published placement_dates' do
        expect(described_class.published).to match_array [published]
      end
    end
  end

  context '#has_limited_availability?' do
    context 'when max_bookings_count' do
      before { subject.max_bookings_count = 7 }

      it 'returns true' do
        expect(subject.has_limited_availability?).to be true
      end
    end

    context 'when no max_bookings_count' do
      before { subject.max_bookings_count = nil }

      it 'returns false' do
        expect(subject.has_limited_availability?).to be false
      end
    end
  end

  context '#published?' do
    context 'when published_at is set' do
      before { subject.published_at = DateTime.now }

      it 'returns true' do
        expect(subject.published?).to be true
      end
    end

    context 'when published_at is not set' do
      before { subject.published_at = nil }

      it 'returns false' do
        expect(subject.published?).to be false
      end
    end
  end
end
