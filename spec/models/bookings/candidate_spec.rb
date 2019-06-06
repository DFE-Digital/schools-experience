require 'rails_helper'

RSpec.describe Bookings::Candidate, type: :model do
  describe 'database structure' do
    it { is_expected.to have_db_column(:gitis_uuid).of_type(:string).with_options(limit: 36) }
    it { is_expected.to have_db_index(:gitis_uuid).unique }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :gitis_uuid }

    it { is_expected.to allow_value(SecureRandom.uuid).for :gitis_uuid }
    it { is_expected.not_to allow_value(nil).for :gitis_uuid }
    it { is_expected.not_to allow_value('').for :gitis_uuid }
    it { is_expected.not_to allow_value('foobar').for :gitis_uuid }

    it do
      is_expected.not_to \
        allow_value(SecureRandom.uuid + SecureRandom.uuid).for :gitis_uuid
    end

    context 'with existing record' do
      before { create(:candidate) }
      it { is_expected.to validate_uniqueness_of(:gitis_uuid).case_insensitive }
    end
  end
end
