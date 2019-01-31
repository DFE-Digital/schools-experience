require 'rails_helper'

RSpec.describe Bookings::SchoolsPhase, type: :model do
  describe 'Relationships' do
    it { is_expected.to belong_to(:bookings_school) }
    it { is_expected.to belong_to(:bookings_phase) }
  end

  describe 'Validation' do
    context '#bookings_school' do
      it { is_expected.to validate_presence_of(:bookings_school) }
    end

    context '#bookings_school' do
      it { is_expected.to validate_presence_of(:bookings_phase) }
    end

    context '#bookings_phase_id' do
      context 'Uniqueness' do
        subject { create(:bookings_schools_phase) }

        it do
          is_expected.to(
            validate_uniqueness_of(:bookings_phase_id)
              .scoped_to(:bookings_school_id)
          )
        end
      end
    end
  end
end
