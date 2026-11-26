require 'rails_helper'

RSpec.describe Bookings::SchoolsPhase, type: :model do
  describe 'Relationships' do
    it { is_expected.to belong_to(:bookings_school) }
    it { is_expected.to belong_to(:bookings_phase) }
  end

  describe 'Validation' do
    describe '#bookings_school' do
      it { is_expected.to validate_presence_of(:bookings_school) }
    end

    describe '#bookings_school' do
      it { is_expected.to validate_presence_of(:bookings_phase) }
    end

    describe '#bookings_phase_id' do
      context 'when checking uniqueness' do
        subject { create(:bookings_schools_phase) }

        it do
          expect(subject).to(
            validate_uniqueness_of(:bookings_phase_id)
              .scoped_to(:bookings_school_id)
          )
        end
      end
    end
  end
end
