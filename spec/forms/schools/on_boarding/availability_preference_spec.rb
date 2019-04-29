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

  context '.new_from_bookings_school' do
    subject { described_class.new_from_bookings_school school }

    context 'when school has availability_info' do
      let :school do
        FactoryBot.build :bookings_school, :with_availability_info
      end

      it 'sets fixed to false' do
        expect(subject.fixed).to be false
      end
    end

    context "when school doesn't have availability_info" do
      let :school do
        FactoryBot.build :bookings_school
      end

      it 'leaves fixed as nil' do
        expect(subject.fixed).to be nil
      end
    end
  end
end
