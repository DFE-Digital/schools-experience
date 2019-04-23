require 'rails_helper'

describe Schools::OnBoarding::AvailabilityPreference, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :fixed }
  end

  context '#fixed?' do
    context 'when fixed' do
      subject { described_class.new fixed: true }

      it 'returns true' do
        expect(subject.fixed?).to be true
      end
    end

    context 'when flexible' do
      subject { described_class.new fixed: false }

      it 'returns false' do
        expect(subject.fixed?).to be false
      end
    end
  end

  context '#flexible?' do
    context 'when fixed' do
      subject { described_class.new fixed: true }

      it 'returns true' do
        expect(subject.flexible?).to be false
      end
    end

    context 'when flexible' do
      subject { described_class.new fixed: false }

      it 'returns false' do
        expect(subject.flexible?).to be true
      end
    end
  end
end
