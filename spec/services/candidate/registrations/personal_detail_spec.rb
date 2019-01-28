require 'rails_helper'

describe Candidate::Registrations::PersonalDetail, type: :model do
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
      personal_detail.validate
    end

    context 'when building is not present' do
      let :personal_detail do
        described_class.new
      end

      it 'adds an error to building' do
        expect(personal_detail.errors[:building]).to eq ["can't be blank"]
      end
    end

    context 'when street is not present' do
      let :personal_detail do
        described_class.new
      end

      it 'adds an error to street' do
        expect(personal_detail.errors[:street]).to eq ["can't be blank"]
      end
    end

    context 'when town_or_city is not present' do
      let :personal_detail do
        described_class.new
      end

      it 'adds an error to town_or_city' do
        expect(personal_detail.errors[:town_or_city]).to eq ["can't be blank"]
      end
    end

    context 'when county is not present' do
      let :personal_detail do
        described_class.new
      end

      it 'adds an error to county' do
        expect(personal_detail.errors[:county]).to eq ["can't be blank"]
      end
    end

    context 'when postcode is not present' do
      let :personal_detail do
        described_class.new
      end

      it 'adds an error to postcode' do
        expect(personal_detail.errors[:postcode]).to eq ["can't be blank"]
      end
    end

    context 'when phone is not present' do
      let :personal_detail do
        described_class.new
      end

      it 'adds an error to phone' do
        expect(personal_detail.errors[:phone]).to eq ["can't be blank"]
      end
    end
  end
end
