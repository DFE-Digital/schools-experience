require 'rails_helper'

describe Schools::OnBoarding::CandidateRequirementsChoice, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :has_requirements }
  end

  context 'validations' do
    it { is_expected.not_to allow_value(nil).for :has_requirements }
  end
end
