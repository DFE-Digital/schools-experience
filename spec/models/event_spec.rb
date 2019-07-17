require 'rails_helper'

describe Event, type: :model do
  describe 'Relationships' do
    specify do
      expect(subject).to belong_to(:bookings_school)
        .class_name('Bookings::School')
        .with_foreign_key(:bookings_school_id)
        .optional
    end
  end

  describe 'Validation' do
    specify do
      expect(subject).to validate_inclusion_of(:event_type).in_array(Event::EVENT_TYPES)
    end

    context 'presence of school or gitis uuid' do
      context 'when both are missing' do
        subject { build(:event, :without_gitis_uuid, :without_bookings_school) }
        specify { expect(subject).not_to be_valid }
      end

      context 'when the school is missing' do
        subject { build(:event, :without_bookings_school) }
        specify { expect(subject).to be_valid }
      end

      context 'when the gitis uuid is missing' do
        subject { build(:event, :without_gitis_uuid) }
        specify { expect(subject).to be_valid }
      end

      context 'when both are present' do
        subject { build(:event) }
        specify { expect(subject).to be_valid }
      end
    end
  end
end
