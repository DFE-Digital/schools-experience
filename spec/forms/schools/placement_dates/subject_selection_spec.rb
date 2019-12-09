require 'rails_helper'

describe Schools::PlacementDates::SubjectSelection, type: :model do
  let :school do
    create :bookings_school, :with_subjects, subject_count: 3
  end

  let! :stubbed_time do
    DateTime.now
  end

  before { allow(DateTime).to receive(:now) { stubbed_time } }

  context 'validations' do
    it { is_expected.to validate_presence_of :subject_ids }
  end

  context '.new_from_date' do
    subject { described_class.new_from_date placement_date }

    context 'published' do
      let :placement_date do
        create \
          :bookings_placement_date,
          published_at: DateTime.now,
          bookings_school: school
      end

      it 'returns a new subject_selection with attributes set' do
        expect(subject.subject_ids).to eq placement_date.subject_ids
      end
    end

    context 'unpublished' do
      let :placement_date do
        create \
          :bookings_placement_date,
          bookings_school: school,
          published_at: nil
      end

      it 'returns a new subject_selection without attributes set' do
        expect(subject.available_for_all_subjects).to eq nil
        expect(subject.subject_ids).to be_empty
      end
    end
  end

  context '#subject_ids=' do
    it 'removes any blank values' do
      subject.subject_ids = ["", "1", "2", "3"]
      expect(subject.subject_ids).to eq %w(1 2 3)
    end
  end

  context '#save' do
    let :placement_date do
      create \
        :bookings_placement_date,
        bookings_school: school,
        published_at: nil,
        subject_specific: true
    end

    before { described_class.new(attributes).save(placement_date) }

    context 'invalid' do
      let :attributes do
        { available_for_all_subjects: nil, subject_ids: nil }
      end

      it 'doesnt update the placement_date' do
        expect(placement_date.published_at).to be nil
      end
    end

    context 'valid' do
      context 'when available_for_all_subjects' do
        let :attributes do
          { available_for_all_subjects: true, subject_ids: [] }
        end

        it 'updates the placement_date to not be subject_specific' do
          expect(placement_date).not_to be_subject_specific
        end

        it 'updates published_at' do
          expect(placement_date.published_at).to eq stubbed_time
        end
      end

      context 'when not available_for_all_subjects' do
        let :subjects do
          school.subjects.first(2)
        end

        let :attributes do
          { available_for_all_subjects: false, subject_ids: subjects.map(&:id) }
        end

        it 'updates the placement_date subjects to the selected_subjects' do
          expect(placement_date.subjects).to eq subjects
        end

        it 'updates published_at' do
          expect(placement_date.published_at).to eq stubbed_time
        end
      end
    end
  end
end
