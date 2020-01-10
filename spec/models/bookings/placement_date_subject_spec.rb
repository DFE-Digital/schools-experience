require 'rails_helper'

describe Bookings::PlacementDateSubject, type: :model do
  describe 'relationships' do
    it { is_expected.to belong_to :bookings_placement_date }
    it { is_expected.to belong_to :bookings_subject }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :bookings_placement_date }
    it { is_expected.to validate_presence_of :bookings_subject }

    context 'bookings_subject' do
      let :school do
        create :bookings_school, :with_subjects, subject_count: 2
      end

      let :placement_date do
        create :bookings_placement_date, bookings_school: school
      end

      before { subject.bookings_placement_date = placement_date }

      it do
        is_expected.to \
          validate_inclusion_of(:bookings_subject_id).in_array(school.subject_ids)
      end
    end

    context '#max_bookings_count' do
      let(:date) { build :bookings_placement_date }
      subject { build :bookings_placement_date_subject, bookings_placement_date: date }

      context 'with no placement_date' do
        before { subject.bookings_placement_date = nil }

        it { is_expected.to allow_value(1).for :max_bookings_count }
        it { is_expected.to allow_value(nil).for :max_bookings_count }
        it { is_expected.not_to allow_value(0).for :max_bookings_count }
        it { is_expected.not_to allow_value(-1).for :max_bookings_count }
        it { is_expected.not_to allow_value(0.5).for :max_bookings_count }
      end

      context 'when placement_date is published' do
        before { subject.bookings_placement_date.published_at = DateTime.now }

        context 'with an uncapped placement_date' do
          before { subject.bookings_placement_date.capped = false }

          it { is_expected.to allow_value(1).for :max_bookings_count }
          it { is_expected.to allow_value(nil).for :max_bookings_count }
          it { is_expected.not_to allow_value(0).for :max_bookings_count }
          it { is_expected.not_to allow_value(-1).for :max_bookings_count }
          it { is_expected.not_to allow_value(0.5).for :max_bookings_count }
        end

        context 'with a capped placement_date' do
          before { subject.bookings_placement_date.capped = true }

          it { is_expected.to allow_value(1).for :max_bookings_count }
          it { is_expected.not_to allow_value(nil).for :max_bookings_count }
          it { is_expected.not_to allow_value(0).for :max_bookings_count }
          it { is_expected.not_to allow_value(-1).for :max_bookings_count }
          it { is_expected.not_to allow_value(0.5).for :max_bookings_count }
        end
      end

      context 'when placement_date is not published' do
        before { subject.bookings_placement_date.published_at = nil }

        context 'with an uncapped placement_date' do
          before { subject.bookings_placement_date.capped = false }

          it { is_expected.to allow_value(1).for :max_bookings_count }
          it { is_expected.to allow_value(nil).for :max_bookings_count }
          it { is_expected.not_to allow_value(0).for :max_bookings_count }
          it { is_expected.not_to allow_value(-1).for :max_bookings_count }
          it { is_expected.not_to allow_value(0.5).for :max_bookings_count }
        end

        context 'with a capped placement_date' do
          before { subject.bookings_placement_date.capped = true }

          it { is_expected.to allow_value(1).for :max_bookings_count }
          it { is_expected.to allow_value(nil).for :max_bookings_count }
          it { is_expected.not_to allow_value(0).for :max_bookings_count }
          it { is_expected.not_to allow_value(-1).for :max_bookings_count }
          it { is_expected.not_to allow_value(0.5).for :max_bookings_count }
        end
      end
    end
  end

  describe 'methods' do
    describe '#date_and_subject_id' do
      let(:placement_date) { create(:bookings_placement_date) }
      let(:chosen_subject) { create(:bookings_subject) }
      subject do
        Bookings::PlacementDateSubject.create(
          bookings_placement_date: placement_date,
          bookings_subject: chosen_subject
        )
      end

      specify 'should be the bookings_placement_date id and own id delimited by an underscore' do
        expect(subject.date_and_subject_id).to eql("#{placement_date.id}_#{chosen_subject.id}")
      end
    end
  end
end
