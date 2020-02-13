require 'rails_helper'

describe Bookings::Booking do
  describe 'Columns' do
    it do
      is_expected.to have_db_column(:bookings_subject_id)
        .of_type(:integer)
        .with_options(null: false)
    end

    it do
      is_expected.to have_db_column(:bookings_placement_request_id)
        .of_type(:integer)
        .with_options(null: false)
    end

    it do
      is_expected.to have_db_column(:bookings_school_id)
        .of_type(:integer)
        .with_options(null: false)
    end

    it do
      is_expected.to have_db_column(:date)
        .of_type(:date)
        .with_options(null: false)
    end

    it do
      is_expected.to have_db_column(:duration)
        .of_type(:integer)
        .with_options(default: 1, null: false)
    end
  end

  describe 'Validation' do
    it { is_expected.to validate_presence_of(:bookings_placement_request) }
    it { is_expected.to validate_presence_of(:bookings_subject) }
    it { is_expected.to validate_presence_of(:bookings_school) }
    it { is_expected.to validate_presence_of(:duration) }
    it { is_expected.to validate_numericality_of(:duration).is_greater_than 0 }

    it { is_expected.to validate_presence_of(:contact_name).on(:create) }
    it { is_expected.to validate_presence_of(:contact_number).on(:create) }
    it { is_expected.to validate_presence_of(:contact_email).on(:create) }
    it { is_expected.to validate_presence_of(:contact_name).on(:acceptance) }
    it { is_expected.to validate_presence_of(:contact_number).on(:acceptance) }
    it { is_expected.to validate_presence_of(:contact_email).on(:acceptance) }
    it { is_expected.to validate_email_format_of(:contact_email).with_message('Enter a valid contact email address') }

    it { is_expected.to allow_value(true).for(:attended).on(:attendance) }
    it { is_expected.to allow_value(false).for(:attended).on(:attendance) }
    it { is_expected.not_to allow_value(nil).for(:attended).on(:attendance) }

    context '#date' do
      it { is_expected.to validate_presence_of(:date) }

      context 'new placement dates must not be in the past' do
        specify 'should allow future dates' do
          [Date.tomorrow, 3.days.from_now, 3.weeks.from_now, 3.months.from_now].each do |d|
            expect(subject).to allow_value(d).for(:date)
          end
        end

        specify 'new placement dates should not allow historic dates' do
          [Date.yesterday, 3.days.ago, 3.weeks.ago, 3.years.ago].each do |d|
            expect(subject).not_to allow_value(d).for(:date)
          end
        end

        specify 'new placement dates should not allow today' do
          expect(subject).not_to allow_value(Date.today).for(:date)
        end

        context 'error messages' do
          let(:message) { 'Date must be in the future' }
          let(:invalid_pd) { build(:bookings_placement_date, date: 3.weeks.ago).tap(&:valid?) }
          subject { invalid_pd.errors.full_messages }

          specify 'should show a suitable error message' do
            is_expected.to include(message)
          end
        end
      end

      context 'updating placement date with same date' do
        let(:booking) { create(:bookings_booking) }
        subject { booking.errors.to_hash }

        context 'defaults to being allowed' do
          before { booking.valid? }
          it { is_expected.to be_empty }
        end

        context 'is disallowed if updating_date is enabled' do
          before { booking.valid?(:updating_date) }
          it { is_expected.to be_any }
          it { is_expected.to include(date: ["Date has not been changed"]) }
        end
      end

      context 'new placement dates must be in the future' do
        context 'not too far in the future' do
          specify 'should not allow dates more than 2 years in the future' do
            expect(subject).not_to allow_value((2.years + 1.day).from_now).for(:date)
            expect(subject).to allow_value((2.years - 1.day).from_now).for(:date)
          end
        end
      end

      context 'attended' do
        context 'when cancelled by candidate' do
          subject { create :bookings_booking, :cancelled_by_candidate }

          specify 'does not allow attended to be set' do
            expect(subject).not_to allow_value(true).for :attended
            expect(subject).not_to allow_value(false).for :attended
          end
        end

        context 'when cancelled by school' do
          subject { create :bookings_booking, :cancelled_by_school }

          specify 'does not allow attended to be set' do
            expect(subject).not_to allow_value(true).for :attended
            expect(subject).not_to allow_value(false).for :attended
          end
        end

        context 'when not cancelled' do
          subject { create :bookings_booking }

          specify 'allows attended to be set' do
            expect(subject).to allow_value(true).for :attended
            expect(subject).to allow_value(false).for :attended
          end
        end
      end
    end
  end

  describe 'Relationships' do
    it { is_expected.to belong_to(:bookings_placement_request) }
    it { is_expected.to belong_to(:bookings_subject) }
    it { is_expected.to belong_to(:bookings_school) }
    it { is_expected.to have_one(:candidate_cancellation).through(:bookings_placement_request) }
    it { is_expected.to have_one(:school_cancellation).through(:bookings_placement_request) }
  end

  describe 'Delegation' do
    %i(
      availability degree_stage degree_stage_explaination degree_subject
      has_dbs_check objectives teaching_stage token closed?
    ).each do |delegated_method|
      it { is_expected.to delegate_method(delegated_method).to(:bookings_placement_request) }
    end
  end

  describe 'Scopes' do
    describe '.not_cancelled' do
      let! :not_cancelled do
        FactoryBot.create :bookings_booking
      end

      let! :booking_cancelled_by_school do
        FactoryBot.create :bookings_booking, :cancelled_by_school
      end

      let! :booking_cancelled_by_candidate do
        FactoryBot.create :bookings_booking, :cancelled_by_candidate
      end

      subject { described_class.not_cancelled }

      it { is_expected.to match_array [not_cancelled] }
    end

    describe '.previous' do
      let!(:previous_bookings) do
        [
          FactoryBot.build(:bookings_booking, date: 1.week.ago),
          FactoryBot.build(:bookings_booking, date: Date.yesterday),
          FactoryBot.build(:bookings_booking, date: Date.today)
        ].each do |booking|
          booking.save(validate: false)
        end
      end

      let!(:non_previous_bookings) do
        [
          FactoryBot.create(:bookings_booking, date: Date.tomorrow),
          FactoryBot.create(:bookings_booking, date: 1.week.from_now)
        ]
      end

      subject { described_class.previous.to_a }

      specify 'should include dates today or before' do
        expect(subject).to match_array(previous_bookings)
      end

      specify 'should not include dates after today' do
        expect(subject).not_to include(*non_previous_bookings)
      end
    end

    describe '.future' do
      let!(:previous_bookings) do
        [
          FactoryBot.build(:bookings_booking, date: 1.week.ago),
          FactoryBot.build(:bookings_booking, date: Date.yesterday)
        ].each do |booking|
          booking.save(validate: false)
        end
      end

      let!(:future_bookings) do
        [
          FactoryBot.build(:bookings_booking, date: Date.today),
          FactoryBot.build(:bookings_booking, date: Date.tomorrow),
          FactoryBot.build(:bookings_booking, date: 3.weeks.from_now)
        ].each do |booking|
          booking.save(validate: false)
        end
      end

      subject { described_class.future }

      specify 'should not include dates before today' do
        expect(subject).not_to include(*previous_bookings)
      end

      specify 'should include dates on or after today' do
        expect(subject).to match_array(future_bookings)
      end
    end

    describe '.attendance_unlogged' do
      let!(:attended) { FactoryBot.create(:bookings_booking, attended: true) }
      let!(:skipped) { FactoryBot.create(:bookings_booking, attended: false) }
      let!(:unlogged) { FactoryBot.create(:bookings_booking) }

      subject { described_class.attendance_unlogged }

      specify 'when attended is nil' do
        expect(subject).to include(unlogged)
      end

      specify 'when attended is not nil' do
        expect(subject).not_to include(attended, skipped)
      end
    end

    describe '.with_unviewed_candidate_cancellation' do
      let!(:new_booking) { create :bookings_booking }
      let!(:with_viewed_candidate_cancellation) { create :bookings_booking, :with_viewed_candidate_cancellation }
      let!(:with_unviewed_candidate_cancellation) { create :bookings_booking, :cancelled_by_candidate }
      let!(:with_unviewed_school_cancellation) { create :bookings_booking, :cancelled_by_school }

      subject { described_class.with_unviewed_candidate_cancellation }

      it { is_expected.to match_array [with_unviewed_candidate_cancellation] }
    end

    describe '.historical' do
      subject { described_class.historical.to_a }

      context 'for previous bookings' do
        let(:previous) { create(:bookings_booking, :previous, :accepted) }

        context 'which have been accepted' do
          let!(:previous_accepted) do
            create(:bookings_booking, :previous, :accepted)
          end
          it { is_expected.to include(previous_accepted) }
        end

        context 'which have not been accepted' do
          let!(:previous_unaccepted) { create(:bookings_booking, :previous) }
          it { is_expected.not_to include(previous_unaccepted) }
        end

        context 'which were attended' do
          let!(:previous_attended) do
            create(:bookings_booking, :previous, :accepted, :attended)
          end

          it { is_expected.to include(previous_attended) }
        end

        context 'which the candidate did not attend' do
          let!(:previous_unattended) do
            create(:bookings_booking, :previous, :accepted, :unattended)
          end

          it { is_expected.to include(previous_unattended) }
        end

        context 'which were cancelled' do
          let!(:previous_cancelled) do
            create(:bookings_booking, :previous, :accepted, :cancelled_by_school)
          end

          it { is_expected.to include(previous_cancelled) }
        end
      end

      context 'for future bookings' do
        context 'which have been accepted' do
          let!(:future_accepted) { create(:bookings_booking, :accepted) }
          it { is_expected.not_to include(future_accepted) }
        end

        context 'which have not been accepted' do
          let!(:future_unaccepted) { create(:bookings_booking) }
          it { is_expected.not_to include(future_unaccepted) }
        end

        context 'which have been cancelled' do
          let!(:future_cancelled) do
            create(:bookings_booking, :accepted, :cancelled_by_school)
          end

          it { is_expected.not_to include(future_cancelled) }
        end
      end
    end

    describe '.days_in_the_future' do
      let!(:booking_in_1_days) { create(:bookings_booking, date: Date.tomorrow) }
      let!(:booking_in_3_days) { create(:bookings_booking, date: 3.days.from_now.to_date) }
      let!(:booking_in_7_days) { create(:bookings_booking, date: 7.days.from_now.to_date) }
      let!(:booking_in_8_days) { create(:bookings_booking, date: 8.days.from_now.to_date) }

      specify 'should return bookings the specified number of days away' do
        expect(described_class.days_in_the_future(1.days)).to include(booking_in_1_days)
      end

      specify 'should not return other bookings' do
        expect(described_class.days_in_the_future(1.days)).not_to include(booking_in_3_days)
        expect(described_class.days_in_the_future(1.days)).not_to include(booking_in_7_days)
        expect(described_class.days_in_the_future(1.days)).not_to include(booking_in_8_days)
      end

      describe '.tomorrow' do
        after { described_class.tomorrow }
        specify 'should call .days_in_the_future with 1 days' do
          expect(described_class).to receive(:days_in_the_future).with(1.day)
        end
      end

      describe '.one_week_from_now' do
        after { described_class.one_week_from_now }
        specify 'should call .days_in_the_future with 7 days' do
          expect(described_class).to receive(:days_in_the_future).with(7.days)
        end
      end
    end
  end

  describe '#placement_start_date_with_duration' do
    context 'when the placement request has a flexible date' do
      let! :date do
        Date.today
      end

      subject { described_class.new date: date }

      specify 'should return the date formatted to GOV.UK style' do
        expect(subject.placement_start_date_with_duration).to eq \
          date.to_formatted_s(:govuk)
      end
    end

    context 'when the placement request has a fixed date' do
      let! :date do
        Date.today
      end

      let(:placement_date) { create(:bookings_placement_date) }
      let(:placement_request) { create(:placement_request, placement_date: placement_date) }

      subject { described_class.new(date: date, duration: 2, bookings_placement_request: placement_request) }

      specify 'should return a the date formatted to GOV.UK style with duration' do
        expect(subject.placement_start_date_with_duration).to eq \
          "#{date.to_formatted_s(:govuk)} for 2 days"
      end
    end
  end

  describe '#reference' do
    subject { create(:bookings_booking) }

    specify 'should be the first 5 characters of the placement reference token' do
      expect(subject.reference).to eql(subject.bookings_placement_request.token.first(5))
    end
  end

  describe '#in_future?' do
    context 'for upcoming booking' do
      subject { build :bookings_booking }
      it { is_expected.to be_in_future }
    end

    context 'for previous booking' do
      subject { build :bookings_booking, :previous }
      it { is_expected.not_to be_in_future }
    end
  end

  context '#cancellable?' do
    context 'for uncancelled future booking' do
      subject { create(:bookings_booking, :accepted) }
      it { is_expected.to be_cancellable }
    end

    context 'for cancelled booking' do
      subject { create(:bookings_booking, :cancelled_by_school) }
      it { is_expected.not_to be_cancellable }
    end

    context 'for past booking' do
      subject { create(:bookings_booking, :previous) }
      it { is_expected.not_to be_cancellable }
    end
  end

  context '#cancellable?' do
    context 'for uncancelled future booking' do
      subject { create(:bookings_booking, :accepted) }
      it { is_expected.to be_editable_date }
    end

    context 'for cancelled booking' do
      subject { create(:bookings_booking, :cancelled_by_school) }
      it { is_expected.not_to be_editable_date }
    end

    context 'for past booking' do
      subject { create(:bookings_booking, :previous) }
      it { is_expected.not_to be_editable_date }
    end
  end

  describe '.from_placement_request' do
    specify { expect(described_class).to respond_to(:from_placement_request) }
    let(:placement_request) { create(:bookings_placement_request, placement_date: placement_date) }
    subject { described_class.from_placement_request(placement_request) }

    context 'when the placement date is in the future' do
      let(:placement_date) { create(:bookings_placement_date) }

      specify 'should set the date' do
        expect(subject.date).to be_present
      end

      specify 'should set the school, placement request, subject and details' do
        expect(subject.bookings_school).to eql(placement_request.school)
        expect(subject.bookings_placement_request).to eql(placement_request)
        expect(subject.bookings_subject_id).to eql(placement_request.requested_subject.id)
        expect(subject.placement_details).to eql(placement_request.school.placement_info)
      end
    end

    context 'when the placement date is in the past' do
      let(:placement_date) { create(:bookings_placement_date, :in_the_past) }

      specify 'should not set the date' do
        expect(subject.date).to be_blank
      end
    end
  end
end
