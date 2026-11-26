require 'rails_helper'

describe Candidates::Registrations::PlacementPreference, type: :model do
  let! :today do
    Time.zone.today
  end

  it_behaves_like 'a registration step'

  include_context 'with a stubbed candidate school'


  context 'with attributes' do
    it { is_expected.to respond_to :urn }
    it { is_expected.to respond_to :objectives }
  end

  context 'when validating' do
    before do
      placement_preference.validate
    end

    context 'when objectives are not present' do
      let :placement_preference do
        described_class.new
      end

      it 'adds an error to objectives' do
        expect(placement_preference.errors[:objectives]).to eq \
          ["Enter what you want to get out of your placement"]
      end
    end

    context 'when objectives are too long' do
      let :placement_preference do
        described_class.new \
          objectives: 151.times.map { 'word' }.join(' ')
      end

      it 'adds an error to objectives' do
        expect(placement_preference.errors[:objectives]).to eq \
          ["Use 150 words or fewer"]
      end
    end
  end
end
