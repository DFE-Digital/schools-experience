require 'rails_helper'

describe Candidate::Registrations::Placement, type: :model do
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
      placement.validate
    end

    context 'when date_start is not present' do
      let :placement do
        described_class.new
      end

      it 'adds an error to date_start' do
        expect(placement.errors[:date_start]).to eq \
          ["can't be blank"]
      end
    end

    context 'when date_start is not a date' do
      let :placement do
        described_class.new date_start: 'Im not a date'
      end

      it 'adds an error to date_start' do
        expect(placement.errors[:date_start]).to eq \
          ["can't be blank"]
      end
    end

    context 'when date_end is not present' do
      let :placement do
        described_class.new
      end

      it 'adds an error to date_end' do
        expect(placement.errors[:date_end]).to eq \
          ["can't be blank"]
      end
    end

    context 'when date_end is not a date' do
      let :placement do
        described_class.new date_end: 'Im not a date'
      end

      it 'adds an error to date_end' do
        expect(placement.errors[:date_end]).to eq \
          ["can't be blank"]
      end
    end

    context 'when date_end is before date_start' do
      let :placement do
        described_class.new \
          date_start: today,
          date_end: (today - 3.days)
      end

      it 'adds an error to date_end' do
        expect(placement.errors[:date_end]).to eq \
          ["should not be before prefered start date"]
      end
    end

    context 'when date_start is in the past' do
      let :placement do
        described_class.new \
          date_start: 3.days.ago,
          date_end: today
      end

      it 'adds an error to date_start' do
        expect(placement.errors[:date_start]).to eq \
          ["should not be in the past"]
      end
    end

    context 'when objectives are not present' do
      let :placement do
        described_class.new
      end

      it 'adds an error to objectives' do
        expect(placement.errors[:objectives]).to eq \
          ["can't be blank"]
      end
    end

    context 'when objectives are too long' do
      let :placement do
        described_class.new \
          objectives: 51.times.map { 'word' }.join(' ')
      end

      it 'adds an error to objectives' do
        expect(placement.errors[:objectives]).to eq \
          ["Please use 50 words or fewer"]
      end
    end

    context 'when access_needs are not a boolean' do
      let :placement do
        described_class.new
      end

      it 'adds an error to access_needs' do
        expect(placement.errors[:access_needs]).to eq \
          ['Please select an option']
      end
    end

    context 'when access_needs are present' do
      context 'when access_needs_details are not present' do
        let :placement do
          described_class.new access_needs: true
        end

        it 'adds an error to access_needs_details' do
          expect(placement.errors[:access_needs_details]).to eq \
            ["can't be blank"]
        end
      end
    end
  end
end
