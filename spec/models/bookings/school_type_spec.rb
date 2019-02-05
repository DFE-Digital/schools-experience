require 'rails_helper'

RSpec.describe Bookings::SchoolType, type: :model do
  describe 'Validation' do
    context 'Name' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(64) }
    end
  end

  describe 'Relationships' do
    specify do
      is_expected.to have_many(:schools).with_foreign_key(:bookings_school_type_id)
    end
  end
end
