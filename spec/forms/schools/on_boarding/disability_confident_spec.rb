require 'rails_helper'

describe Schools::OnBoarding::DisabilityConfident, type: :model do
  context 'with attributes' do
    it { is_expected.to respond_to :is_disability_confident }
  end

  context 'when validating' do
    it { is_expected.not_to allow_value(nil).for :is_disability_confident }
  end
end
