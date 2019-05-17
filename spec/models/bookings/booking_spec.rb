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
  end

  describe 'Validation' do
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:bookings_placement_request) }
    it { is_expected.to validate_presence_of(:bookings_subject) }
    it { is_expected.to validate_presence_of(:bookings_school) }
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
      let!(:included) { [0,1,13,14].map { |offset| create(:bookings_booking, date: offset.days.from_now) } }
      let!(:excluded) { [-4,-1,15, 50].map { |offset| create(:bookings_booking, date: offset.days.from_now) } }

      specify 'should include bookings that fall within the range' do
        expect(described_class.upcoming).to match_array(included)
      end

      specify 'should not include bookings that fall outside the range' do
        excluded.each { |e| expect(described_class.upcoming).not_to include(e) }
      end
    end
  end
end
