require 'rails_helper'

describe Schools::OnBoarding::AccessNeedsPolicy, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :has_access_needs_policy }
    it { is_expected.to respond_to :url }
  end

  context 'validation' do
    it { is_expected.not_to allow_value(nil).for :has_access_needs_policy }

    context 'when has policy' do
      before { subject.has_access_needs_policy = true }
      it { is_expected.to validate_presence_of :url }
    end

    context 'when doesnt have policy' do
      before { subject.has_access_needs_policy = false }
      it { is_expected.not_to validate_presence_of :url }
    end
  end
end
