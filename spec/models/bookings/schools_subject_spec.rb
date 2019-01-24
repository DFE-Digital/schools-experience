require 'rails_helper'

RSpec.describe Bookings::SchoolsSubject, type: :model do
  describe 'Relationships' do
    it { is_expected.to belong_to(:bookings_school).optional }
    it { is_expected.to belong_to(:bookings_subject).optional }
  end

  describe 'Validation' do
    context '#bookings_school_id' do
      it { is_expected.to validate_presence_of(:bookings_school_id) }
    end

    context '#bookings_subject_id' do
      it { is_expected.to validate_presence_of(:bookings_subject_id) }

      context 'Uniqueness' do
        subject { create(:bookings_schools_subject) }

        it do
          is_expected.to(
            validate_uniqueness_of(:bookings_subject_id)
              .scoped_to(:bookings_school_id)
          )
        end
      end
    end
  end
end
