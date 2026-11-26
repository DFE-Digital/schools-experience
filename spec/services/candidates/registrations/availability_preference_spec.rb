require 'rails_helper'

describe Candidates::Registrations::AvailabilityPreference, type: :model do
  let! :today do
    Time.zone.today
  end

  it_behaves_like 'a registration step'

  include_context 'Stubbed candidates school'


  context 'attributes' do
    it { is_expected.to respond_to :availability }
  end

  context 'validations' do
    before do
      availability_preference.validate
    end

    context 'when availability are not present' do
      let :availability_preference do
        described_class.new
      end

      it 'adds an error to availability' do
        expect(availability_preference.errors[:availability]).to eq \
          ["Enter your availability"]
      end
    end

    context 'when availability are too long' do
      let :availability_preference do
        described_class.new \
          availability: 151.times.map { 'word' }.join(' ')
      end

      it 'adds an error to availability' do
        expect(availability_preference.errors[:availability]).to eq \
          ["Use 150 words or fewer"]
      end
    end
  end
end
