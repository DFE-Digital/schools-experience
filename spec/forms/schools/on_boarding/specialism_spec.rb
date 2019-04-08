require 'rails_helper'

describe Schools::OnBoarding::Specialism, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :has_specialism }
    it { is_expected.to respond_to :details }
  end

  context 'validations' do
    context '#has_specialism' do
      it { is_expected.not_to allow_value(nil).for :has_specialism }
    end

    context '#details' do
      context 'does not have specialism' do
        subject { described_class.new has_specialism: false }
        it { is_expected.not_to validate_presence_of :details }
      end

      context 'when has specialism' do
        subject { described_class.new has_specialism: true }
        it { is_expected.to validate_presence_of :details }
      end
    end
  end
end
