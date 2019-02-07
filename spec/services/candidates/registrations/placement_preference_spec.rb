require 'rails_helper'

describe Candidates::Registrations::PlacementPreference, type: :model do
  it_behaves_like 'a registration step'

  let! :today do
    Date.today
  end

  context 'attributes' do
    it { is_expected.to respond_to :date_start }
    it { is_expected.to respond_to :date_end }
    it { is_expected.to respond_to :objectives }
    it { is_expected.to respond_to :access_needs }
  end

  context 'validations' do
    before :each do
      placement_preference.validate
    end

    context 'when date_start is not present' do
      let :placement_preference do
        described_class.new
      end

      it 'adds an error to date_start' do
        expect(placement_preference.errors[:date_start]).to eq \
          ["Enter a start date"]
      end
    end

    context 'when date_start is not a date' do
      let :placement_preference do
        described_class.new date_start: 'Im not a date'
      end

      it 'adds an error to date_start' do
        expect(placement_preference.errors[:date_start]).to eq \
          ["Enter a start date"]
      end
    end

    context 'when date_end is not present' do
      let :placement_preference do
        described_class.new
      end

      it 'adds an error to date_end' do
        expect(placement_preference.errors[:date_end]).to eq \
          ["Enter an end date"]
      end
    end

    context 'when date_end is not a date' do
      let :placement_preference do
        described_class.new date_end: 'Im not a date'
      end

      it 'adds an error to date_end' do
        expect(placement_preference.errors[:date_end]).to eq \
          ["Enter an end date"]
      end
    end

    context 'when date_end is before date_start' do
      let :placement_preference do
        described_class.new \
          date_start: today,
          date_end: (today - 3.days)
      end

      it 'adds an error to date_end' do
        expect(placement_preference.errors[:date_end]).to eq \
          ["End date must not be earlier than start date"]
      end
    end

    context 'when date_start is in the past' do
      let :placement_preference do
        described_class.new \
          date_start: 3.days.ago,
          date_end: today
      end

      it 'adds an error to date_start' do
        expect(placement_preference.errors[:date_start]).to eq \
          ["Must not be in the past"]
      end
    end

    context 'when objectives are not present' do
      let :placement_preference do
        described_class.new
      end

      it 'adds an error to objectives' do
        expect(placement_preference.errors[:objectives]).to eq \
          ["Enter what you want to get out of a placement"]
      end
    end

    context 'when objectives are too long' do
      let :placement_preference do
        described_class.new \
          objectives: 51.times.map { 'word' }.join(' ')
      end

      it 'adds an error to objectives' do
        expect(placement_preference.errors[:objectives]).to eq \
          ["Please use 50 words or fewer"]
      end
    end

    context 'when access_needs are not a boolean' do
      let :placement_preference do
        described_class.new
      end

      it 'adds an error to access_needs' do
        expect(placement_preference.errors[:access_needs]).to eq \
          ['Select an option']
      end
    end

    context 'when access_needs are present' do
      context 'when access_needs_details are not present' do
        let :placement_preference do
          described_class.new access_needs: true
        end

        it 'adds an error to access_needs_details' do
          expect(placement_preference.errors[:access_needs_details]).to eq \
            ["Enter details"]
        end
      end
    end
  end
end
