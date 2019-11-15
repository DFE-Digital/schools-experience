require 'rails_helper'

describe Schools::PlacementDates::ConfigurationForm, type: :model do
  let :school do
    create :bookings_school, :with_subjects, subject_count: 3
  end

  let! :stubbed_time do
    DateTime.now
  end

  before { allow(DateTime).to receive(:now) { stubbed_time } }

  context '.new_from_date' do
    subject { described_class.new_from_date placement_date }

    context 'when the placement_date has already been published' do
      let :placement_date do
        create \
          :bookings_placement_date,
          published_at: DateTime.now,
          bookings_school: school,
          max_bookings_count: 3,
          subject_specific: false
      end

      it 'returns a new subject selection with attributes set' do
        expect(subject.available_for_all_subjects).to be true
        expect(subject.max_bookings_count).to eq 3
        expect(subject.has_limited_availability).to be true
      end
    end

    context 'when the placement_date has not already been published' do
      let :placement_date do
        create \
          :bookings_placement_date, bookings_school: school, published_at: nil
      end

      it 'returns a new subject selection without attributes set' do
        expect(subject.available_for_all_subjects).to be nil
        expect(subject.max_bookings_count).to be nil
        expect(subject.has_limited_availability).to be nil
      end
    end
  end

  context '#save' do
    before { described_class.new(attributes).save(placement_date) }

    context 'for a unpublished placement_date' do
      let :placement_date do
        create \
          :bookings_placement_date, bookings_school: school, published_at: nil
      end

      context 'when invalid' do
        let :attributes do
          {
             max_bookings_count: nil,
             has_limited_availability: true,
             available_for_all_subjects: true
          }
        end

        it 'doesnt update the placement request' do
          expect(placement_date.has_limited_availability?).to be false
        end
      end

      context 'when valid' do
        context 'when available_for_all_subjects' do
          let :max_bookings_count do
            5
          end

          let :attributes do
            {
              max_bookings_count: max_bookings_count,
              has_limited_availability: true,
              available_for_all_subjects: true,
              supports_subjects: true
            }
          end

          it 'sets subject_specific' do
            expect(placement_date).not_to be_subject_specific
          end

          it 'sets published_at' do
            expect(placement_date.published_at).to eq stubbed_time
          end
        end

        context 'when doesnt support subjects' do
          let :max_bookings_count do
            nil
          end

          let :attributes do
            {
              max_bookings_count: max_bookings_count,
              has_limited_availability: false,
              supports_subjects: false
            }
          end

          it 'sets subject specific' do
            expect(placement_date).not_to be_subject_specific
          end

          it 'empties subject_ids' do
            expect(placement_date.subjects).to be_empty
          end

          it 'sets published_at' do
            expect(placement_date).to be_published
          end
        end

        context 'when not available_for_all_subjects' do
          let :max_bookings_count do
            nil
          end

          let :attributes do
            {
              max_bookings_count: max_bookings_count,
              has_limited_availability: false,
              available_for_all_subjects: false,
              supports_subjects: true
            }
          end

          it 'sets subject_specific' do
            expect(placement_date).to be_subject_specific
          end

          it 'sets published_at to nil' do
            expect(placement_date.published_at).to eq nil
          end
        end
      end
    end

    context 'for a published placement_date' do
      let :placement_date do
        create \
          :bookings_placement_date,
          bookings_school: school,
          subjects: school.subjects,
          subject_specific: true,
          max_bookings_count: nil
      end

      context 'when invalid' do
        let :attributes do
          {
             max_bookings_count: nil,
             has_limited_availability: true,
             available_for_all_subjects: true
          }
        end

        it 'doesnt update the placement request' do
          expect(placement_date.has_limited_availability?).to be false
          expect(placement_date).to be_subject_specific
        end
      end

      context 'when valid' do
        context 'when available_for_all_subjects' do
          let :max_bookings_count do
            5
          end

          let :attributes do
            {
              max_bookings_count: max_bookings_count,
              has_limited_availability: true,
              available_for_all_subjects: true,
              supports_subjects: true
            }
          end

          it 'remove existing specific subjects' do
            expect(placement_date.subjects).to be_empty
            expect(placement_date).not_to be_subject_specific
          end
        end

        context 'when not available_for_all_subjects' do
          let :max_bookings_count do
            5
          end

          let :attributes do
            {
              max_bookings_count: max_bookings_count,
              has_limited_availability: true,
              available_for_all_subjects: false,
              supports_subjects: true
            }
          end

          it 'unpublishes the placement date before the next step' do
            expect(placement_date).not_to be_published
          end
        end
      end
    end
  end

  context '#subject_specific?' do
    context 'when the date doesnt support subjects' do
      subject { described_class.new supports_subjects: false }
      it { is_expected.not_to be_subject_specific }
    end

    context 'when the date supports subject' do
      context 'when the date is available_for_all_subjects' do
        subject { described_class.new supports_subjects: true, available_for_all_subjects: true }
        it { is_expected.not_to be_subject_specific }
      end

      context 'when the date is not available_for_all_subjects' do
        subject { described_class.new supports_subjects: true, available_for_all_subjects: false }
        it { is_expected.to be_subject_specific }
      end
    end
  end
end
