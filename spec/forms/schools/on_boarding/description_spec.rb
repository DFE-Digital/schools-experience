require 'rails_helper'

describe Schools::OnBoarding::Description, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :details }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :details }
  end
end
