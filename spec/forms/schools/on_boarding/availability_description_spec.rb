require 'rails_helper'

describe Schools::OnBoarding::AvailabilityDescription, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :description }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :description }
  end
end
