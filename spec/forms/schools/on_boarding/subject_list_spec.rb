require 'rails_helper'

describe Schools::OnBoarding::SubjectList, type: :model do
  context '#attibutes' do
    it { is_expected.to respond_to :subject_ids }
  end

  context '#subject_ids' do
    it 'removes blank values' do
      expect(described_class.new(subject_ids: [""]).subject_ids).to eq []
    end

    it 'converts strings to integers' do
      expect(described_class.new(subject_ids: %w(2)).subject_ids).to eq [2]
    end
  end

  context 'validations' do
    context 'when no subjects selected' do
      subject { described_class.new subject_ids: [] }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to eq ['Select at least one subject']
      end
    end

    context 'when non existent subject ids selected' do
      let :bookings_subject do
        FactoryBot.create :bookings_subject
      end

      subject { described_class.new subject_ids: [bookings_subject.id + 1] }

      it 'is invalid' do
        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to eq ['Subject not available']
      end
    end
  end
end
