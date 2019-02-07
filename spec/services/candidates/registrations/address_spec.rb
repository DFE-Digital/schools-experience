require 'rails_helper'

describe Candidates::Registrations::Address, type: :model do
  it_behaves_like 'a registration step'

  context 'attributes' do
    it { is_expected.to respond_to :building }
    it { is_expected.to respond_to :street }
    it { is_expected.to respond_to :town_or_city }
    it { is_expected.to respond_to :county }
    it { is_expected.to respond_to :postcode }
    it { is_expected.to respond_to :phone }
  end

  context 'validations' do
    before :each do
      address.validate
    end

    context 'when building is not present' do
      let :address do
        described_class.new
      end

      it 'adds an error to building' do
        expect(address.errors[:building]).to eq ["Enter a building"]
      end
    end

    context 'when street is not present' do
      let :address do
        described_class.new
      end

      it 'adds an error to street' do
        expect(address.errors[:street]).to eq ["Enter a street"]
      end
    end

    context 'when town_or_city is not present' do
      let :address do
        described_class.new
      end

      it 'adds an error to town_or_city' do
        expect(address.errors[:town_or_city]).to eq \
          ["Enter a town or city"]
      end
    end

    context 'when county is not present' do
      let :address do
        described_class.new
      end

      it 'adds an error to county' do
        expect(address.errors[:county]).to eq ["Enter a county"]
      end
    end

    context 'when postcode is not present' do
      let :address do
        described_class.new
      end

      it 'adds an error to postcode' do
        expect(address.errors[:postcode]).to eq ["Enter a postcode"]
      end
    end

    context 'when phone is not present' do
      let :address do
        described_class.new
      end

      it 'adds an error to phone' do
        expect(address.errors[:phone]).to eq \
          ["Enter a telephone number"]
      end
    end
  end
end
