require 'rails_helper'

describe Schools::OnBoarding::Description, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :details }
  end

  context 'validations' do
    context 'details' do
      context 'when blank' do
        subject { described_class.new details: '' }

        it 'is valid' do
          expect(subject).to be_valid
        end
      end

      context 'when nil' do
        subject { described_class.new }

        it 'is not valid' do
          expect(subject).not_to be_valid
          expect(subject.errors[:details]).to eq ["can't be nil"]
        end
      end
    end
  end
end
