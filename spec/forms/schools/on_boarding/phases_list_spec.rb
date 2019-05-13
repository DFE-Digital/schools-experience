require 'rails_helper'

describe Schools::OnBoarding::PhasesList, type: :model do
  context '#attributes' do
    it { is_expected.to respond_to :primary }
    it { is_expected.to respond_to :secondary }
    it { is_expected.to respond_to :college }
    it { is_expected.to respond_to :secondary_and_college }
  end

  context '#validations' do
    it 'validates at_least_one_phase_offered' do
      expect(described_class.new.tap(&:validate).errors[:base]).to \
        eq ['Select at least one phase']
    end
  end

  context '#primary?' do
    context 'primary selected' do
      subject { described_class.new primary: true }

      it 'returns true' do
        expect(subject.primary?).to be true
      end
    end

    context 'primary not selected' do
      subject { described_class.new primary: false }

      it 'returns false' do
        expect(subject.primary?).to be false
      end
    end
  end

  context '#secondary?' do
    context 'secondary selected' do
      subject { described_class.new secondary: true }

      it 'returns true' do
        expect(subject.secondary?).to be true
      end
    end

    context 'secondary not selected' do
      context 'secondary_and_college selected' do
        subject do
          described_class.new secondary: false, secondary_and_college: true
        end

        it 'returns true' do
          expect(subject.secondary?).to be true
        end
      end

      context 'secondary_and_college not selected' do
        subject do
          described_class.new secondary: false, secondary_and_college: false
        end

        it 'returns false' do
          expect(subject.secondary?).to be false
        end
      end
    end
  end

  context '#college?' do
    context 'college selected' do
      subject { described_class.new college: true }

      it 'returns true' do
        expect(subject.college?).to be true
      end
    end

    context 'college not selected' do
      context 'secondary_and_college selected' do
        subject do
          described_class.new college: false, secondary_and_college: true
        end

        it 'returns true' do
          expect(subject.college?).to be true
        end
      end

      context 'secondary_and_college not selected' do
        subject do
          described_class.new college: false, secondary_and_college: false
        end

        it 'returns false' do
          expect(subject.college?).to be false
        end
      end
    end
  end

  context '.new_from_bookings_school' do
    let :school do
      FactoryBot.create :bookings_school, :with_primary_key_stage_info
    end

    subject { described_class.new_from_bookings_school school }

    it 'sets the attributes from the bookings_school' do
      expect(subject.primary?).to be true
      expect(subject.secondary?).to be false
      expect(subject.college?).to be false
    end
  end
end
