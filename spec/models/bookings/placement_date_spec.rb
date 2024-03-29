require 'rails_helper'

describe Bookings::PlacementDate, type: :model do
  include ActiveSupport::Testing::TimeHelpers

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
    it { is_expected.to have_db_column(:start_availability_offset).of_type(:integer).with_options(default: 60, null: false) }
    it { is_expected.to have_db_column(:end_availability_offset).of_type(:integer).with_options(default: 0, null: false) }
    it { is_expected.to have_db_column(:recurring).of_type(:boolean).with_options(default: false, null: true) }
  end

  describe 'Validation' do
    subject { described_class.new }

    context "#recurring" do
      it { is_expected.to allow_values(true, false).for :recurring }
      it { is_expected.not_to allow_value(nil).for :recurring }
    end

    context '#date' do
      it { expect(subject).to validate_presence_of(:date) }

      context 'new placement dates must not be in the past' do
        specify 'should allow future dates' do
          next_monday = Date.today.next_occurring(:monday)
          [next_monday, next_monday + 1.day, 3.weeks.from_now.next_occurring(:wednesday), 3.months.from_now.next_occurring(:friday)].each do |d|
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
          before do
            expired_pd.bookings_school = school
            expired_pd.save(validate: false)
          end

          specify 'should allow updates' do
            expect(expired_pd.update(active: false)).to be(true)
            expect(expired_pd).to_not be_active
          end
        end

        context 'not too far in the future' do
          specify 'should not allow dates more than 2 years in the future' do
            expect(subject).not_to allow_value((2.years + 1.day).from_now.next_occurring(:monday)).for(:date)
            expect(subject).to allow_value((2.years - 1.day).from_now.beginning_of_week).for(:date)
          end
        end

        it "does not allow dates that fall on a weekend" do
          expect(subject).not_to allow_values(
            Date.today.next_occurring(:saturday),
            Date.today.next_occurring(:sunday)
          ).for(:date)
        end
      end
    end

    context '#bookings_school' do
      it { expect(subject).to validate_presence_of(:bookings_school) }
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
      subject { date.active }

      context "when active is false" do
        let!(:date) { create(:bookings_placement_date, active: false) }

        it { is_expected.to be false }
      end

      context "when active is true" do
        let!(:date) { create(:bookings_placement_date, active: true) }

        it { is_expected.to be true }
      end
    end

    context ".inside_availability_window" do
      subject { described_class.inside_availability_window }

      it 'includes placements that have not yet closed' do
        travel_to Date.new(2022, 1, 8)

        is_expected.to include(create(:bookings_placement_date, date: Date.new(2022, 1, 10), end_availability_offset: 1))
      end

      it 'does not include placements that closed today' do
        travel_to Date.new(2022, 1, 9)

        is_expected.to_not include(create(:bookings_placement_date, date: Date.new(2022, 1, 10), end_availability_offset: 1))
      end

      it 'does not include placements closed to candidates in the past' do
        travel_to Date.new(2022, 1, 10)

        is_expected.to_not include(create(:bookings_placement_date, date: Date.new(2022, 1, 20), end_availability_offset: 15))
      end

      it 'includes placements that opened today' do
        travel_to Date.new(2022, 1, 8)

        is_expected.to include(create(:bookings_placement_date, date: Date.new(2022, 1, 9), start_availability_offset: 1))
      end

      it 'does not include placements that open tomorrow' do
        travel_to Date.new(2022, 1, 8)

        is_expected.to_not include(create(:bookings_placement_date, date: Date.new(2022, 1, 10), start_availability_offset: 1))
      end

      it 'includes placements that opened in the past' do
        travel_to Date.new(2022, 1, 10)

        is_expected.to include(create(:bookings_placement_date, date: Date.new(2022, 1, 20), start_availability_offset: 20))
      end
    end

    context '.available' do
      after { described_class.available }
      specify 'should combine the future, active, published, open_to_candidates, and in_date_order scopes' do
        expect(described_class).to receive_message_chain(:published, :active, :bookable_date, :inside_availability_window, :in_date_order)
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

  describe "#mark_as_publishable!" do
    let(:placement_date) { create(:bookings_placement_date, publishable: false) }

    it "marks the date as publishable" do
      expect { placement_date.mark_as_publishable! }.to change { placement_date.publishable }.from(false).to(true)
    end
  end

  describe "#publish" do
    let(:recurrences) { [] }
    let(:date) { 3.weeks.from_now.next_occurring(:monday) }

    subject(:published_placement_date) do
      freeze_time

      create(:bookings_placement_date, date: date, active: false, published_at: nil, publishable: false).tap do |pd|
        pd.publish!(recurrences)
      end
    end

    it { is_expected.to be_active }
    it { is_expected.to be_publishable }
    it { expect(published_placement_date.published_at.to_date).to eq(Date.today) }

    context "when there are published_placement_date" do
      let(:recurrences) { [date + 1.day] }

      it "publishes recurrences" do
        expected_attributes = published_placement_date.attributes.except("created_at", "updated_at", "id", "date")
        recurrence = described_class.find_by(date: recurrences.first)
        expect(recurrence).to have_attributes(expected_attributes)
      end
    end
  end

  describe "#recur" do
    let(:placement_date) { create(:bookings_placement_date, bookings_school: school) }

    before do
      placement_date.subject_specific = true
      placement_date.subject_ids = school.subjects.pluck(:id)
      placement_date.save!
    end

    subject { placement_date.recur(Date.new(2022, 1, 3)) }

    it { is_expected.to have_attributes(placement_date.attributes.except("created_at", "updated_at", "id", "date")) }
    it { is_expected.to have_attributes(date: Date.new(2022, 1, 3)) }
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

  context "available?" do
    context "when not active" do
      before { subject.active = false }

      it 'returns false' do
        expect(subject.available?).to be false
      end
    end

    context "when active" do
      it 'includes placements that have not yet closed' do
        travel_to Date.new(2022, 1, 8)
        subject.end_availability_offset = 1
        subject.date = Date.new(2022, 1, 10)

        expect(subject.available?).to be true
      end

      it 'does not include placements that closed today' do
        travel_to Date.new(2022, 1, 9)
        subject.end_availability_offset = 1
        subject.date = Date.new(2022, 1, 10)

        expect(subject.available?).to be false
      end

      it 'does not include placements closed to candidates in the past' do
        travel_to Date.new(2022, 1, 10)
        subject.end_availability_offset = 15
        subject.date = Date.new(2022, 1, 20)

        expect(subject.available?).to be false
      end

      it 'includes placements that opened today' do
        travel_to Date.new(2022, 1, 8)
        subject.start_availability_offset = 1
        subject.date = Date.new(2022, 1, 9)

        expect(subject.available?).to be true
      end

      it 'does not include placements that open tomorrow' do
        travel_to Date.new(2022, 1, 8)
        subject.start_availability_offset = 1
        subject.date = Date.new(2022, 1, 10)

        expect(subject.available?).to be false
      end

      it 'includes placements that opened in the past' do
        travel_to Date.new(2022, 1, 8)
        subject.start_availability_offset = 20
        subject.date = Date.new(2022, 1, 20)

        expect(subject.available?).to be true
      end
    end
  end

  describe "#experience_type" do
    context "when it's a Virtual date" do
      subject { create(:bookings_placement_date, :virtual) }

      it "returns 'virtual'" do
        expect(subject.experience_type).to eq('virtual')
      end
    end

    context "when it's an Inschool date" do
      subject { create(:bookings_placement_date) }

      it "returns 'inschool'" do
        expect(subject.experience_type).to eq('inschool')
      end
    end
  end
end
