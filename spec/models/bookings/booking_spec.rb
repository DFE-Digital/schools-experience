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

    context '#date' do
      it { is_expected.to validate_presence_of(:date) }

      context 'new placement dates must be in the future' do
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

        context 'error messages' do
          let(:message) { 'Validation failed: Date must be in the future' }
          let(:invalid_pd) { create(:bookings_placement_date, date: 3.weeks.ago) }

          specify 'should show a suitable error message' do
            expect { invalid_pd }.to(
              raise_error(ActiveRecord::RecordInvalid, message)
            )
          end
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
    end
  end

  describe 'Relationships' do
    it { is_expected.to belong_to(:bookings_placement_request) }
    it { is_expected.to belong_to(:bookings_subject) }
    it { is_expected.to belong_to(:bookings_school) }
  end

  describe 'Delegation' do
    %i(
      availability degree_stage degree_stage_explaination degree_subject
      has_dbs_check objectives teaching_stage
    ).each do |delegated_method|
      it { is_expected.to delegate_method(delegated_method).to(:bookings_placement_request) }
    end
  end

  describe 'Scopes' do
    describe '.upcoming' do
      # upcoming is currently set to any date within the next 2 weeks
      let!(:included) { [0, 1, 13, 14].map { |offset| create(:bookings_booking, date: offset.days.from_now) } }
      let!(:excluded) { [-4, -1, 15, 50].map { |offset| build(:bookings_booking, date: offset.days.from_now).save(validate: false) } }

      specify 'should include bookings that fall within the range' do
        expect(described_class.upcoming).to match_array(included)
      end

      specify 'should not include bookings that fall outside the range' do
        excluded.each { |e| expect(described_class.upcoming).not_to include(e) }
      end
    end
  end

  describe 'Acceptance' do
    let(:booking_confirmed_params) do
      {
        date: 3.weeks.from_now,
        placement_details: "an amazing experience"
      }
    end

    let(:more_details_params) do
      booking_confirmed_params.merge(
        contact_name: 'Gary Chalmers',
        contact_email: 'gary.chalmers@springfield.edu',
        contact_number: '01234 456 678',
        location: 'Near the assembly hall'
      )
    end

    let(:reviewed_and_email_sent_params) do
      more_details_params.merge(
        candidate_instructions: 'Just go down the main corridor then turn left'
      )
    end

    describe '#booking_confirmed?' do
      context 'when the relevant attributes are present' do
        subject do
          create(:bookings_booking, **booking_confirmed_params)
        end

        specify 'should be true' do
          expect(subject).to be_booking_confirmed
        end
      end

      context 'when the relevant attributes are absent' do
        subject do
          create(
            :bookings_booking,
            **booking_confirmed_params.except(:placement_details)
          )
        end

        specify 'should be false' do
          expect(subject).not_to be_booking_confirmed
        end
      end
    end

    describe '#more_details_added?' do
      context 'when the relevant attributes are present' do
        subject do
          create(:bookings_booking, **more_details_params)
        end

        specify 'should be true' do
          expect(subject).to be_more_details_added
        end
      end

      context 'when the relevant attributes are absent' do
        subject do
          create(:bookings_booking, **more_details_params.except(:contact_name))
        end

        specify 'should be false' do
          expect(subject).not_to be_more_details_added
        end
      end
    end

    describe '#reviewed_and_candidate_instructions_added?' do
      context 'when the relevant attributes are present' do
        subject do
          create(:bookings_booking, **reviewed_and_email_sent_params)
        end

        specify 'should be true' do
          expect(subject).to be_reviewed_and_candidate_instructions_added
        end
      end

      context 'when the relevant attributes are absent' do
        subject do
          create(:bookings_booking, **reviewed_and_email_sent_params.except(:candidate_instructions))
        end

        specify 'should be false' do
          expect(subject).not_to be_reviewed_and_candidate_instructions_added
        end
      end
    end

    describe '#accepted?' do
      context 'when the relevant attributes are present' do
        subject do
          create(:bookings_booking, :accepted)
        end

        specify 'should be true' do
          expect(subject).to be_accepted
        end
      end

      context 'when the relevant attributes are absent' do
        subject do
          create(:bookings_booking)
        end

        specify 'should be false' do
          expect(subject).not_to be_accepted
        end
      end
    end
  end
end
