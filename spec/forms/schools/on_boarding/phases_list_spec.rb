require 'rails_helper'

describe Schools::OnBoarding::PhasesList, type: :model do
  context '#attributes' do
    it { is_expected.to respond_to :primary }
    it { is_expected.to respond_to :secondary }
    it { is_expected.to respond_to :college }
  end

  context '#validations' do
    it 'validates at_least_one_phase_offered' do
      expect(described_class.new.tap(&:validate).errors[:base]).to \
        eq ['Select at least one phase']
    end
  end
end
