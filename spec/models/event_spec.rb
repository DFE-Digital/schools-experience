require 'rails_helper'

describe Event, type: :model do
  describe 'Relationships' do
    specify do
      expect(subject).to belong_to(:bookings_school)
        .class_name('Bookings::School')
        .with_foreign_key(:bookings_school_id)
        .optional
    end

    specify do
      expect(subject).to belong_to(:recordable).optional
    end
  end

  describe 'Validation' do
    specify do
      expect(subject).to validate_inclusion_of(:event_type).in_array(Event::EVENT_TYPES)
    end

    context 'presence of school or candidate' do
      context 'when both are missing' do
        subject { build(:event, :without_bookings_candidate, :without_bookings_school) }
        specify { expect(subject).not_to be_valid }
      end

      context 'when the school is missing' do
        subject { create(:event, :without_bookings_school) }
        specify { expect(subject).to be_valid }
      end

      context 'when the candidate is missing' do
        subject { create(:event, :without_bookings_candidate) }
        specify { expect(subject).to be_valid }
      end

      context 'when both are present' do
        subject { create(:event) }
        specify { expect(subject).to be_valid }
      end
    end
  end
end
