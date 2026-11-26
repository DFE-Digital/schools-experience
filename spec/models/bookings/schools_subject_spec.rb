require 'rails_helper'

RSpec.describe Bookings::SchoolsSubject, type: :model do
  describe 'Relationships' do
    it { is_expected.to belong_to(:bookings_school) }
    it { is_expected.to belong_to(:bookings_subject) }
  end

  describe 'Validation' do
    describe '#bookings_school' do
      it { is_expected.to validate_presence_of(:bookings_school) }
    end

    describe '#bookings_subject' do
      it { is_expected.to validate_presence_of(:bookings_subject) }

      context 'when checking uniqueness' do
        subject { create(:bookings_schools_subject) }

        it do
          expect(subject).to(
            validate_uniqueness_of(:bookings_subject_id)
              .scoped_to(:bookings_school_id)
          )
        end
      end
    end
  end
end
