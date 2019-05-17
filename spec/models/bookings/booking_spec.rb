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
end
