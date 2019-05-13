require 'rails_helper'

describe Schools::OnBoarding::KeyStageList, type: :model do
  context '#attributes' do
    it { is_expected.to respond_to :early_years }
    it { is_expected.to respond_to :key_stage_1 }
    it { is_expected.to respond_to :key_stage_2 }
  end

  context '#validations' do
    it 'validates at_least_one_key_stage_offered' do
      expect(described_class.new.tap(&:validate).errors[:base]).to \
        eq ['Select at least one key stage']
    end
  end

  context '.new_from_bookings_school' do
    let :school do
      FactoryBot.build :bookings_school, :with_primary_key_stage_info
    end

    subject { described_class.new_from_bookings_school school }

    it 'sets the attributes from the bookings_school' do
      expect(subject.early_years).to be true
      expect(subject.key_stage_1).to be true
      expect(subject.key_stage_2).to be true
    end
  end
end
