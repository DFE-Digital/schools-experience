require 'rails_helper'

describe Bookings::PlacementDateSubject, type: :model do
  context 'with relationships' do
    it { is_expected.to belong_to :bookings_placement_date }
    it { is_expected.to belong_to :bookings_subject }
  end

  context 'when validating' do
    it { is_expected.to validate_presence_of :bookings_placement_date }
    it { is_expected.to validate_presence_of :bookings_subject }

    context 'when bookings_subject' do
      let :school do
        create :bookings_school, :with_subjects, subject_count: 2
      end

      let :placement_date do
        create :bookings_placement_date, bookings_school: school
      end

      before { subject.bookings_placement_date = placement_date }

      it do
        expect(subject).to \
          validate_inclusion_of(:bookings_subject_id).in_array(school.subject_ids)
      end
    end
  end

  describe 'methods' do
    describe '#date_and_subject_id' do
      subject do
        described_class.create(
          bookings_placement_date: placement_date,
          bookings_subject: chosen_subject
        )
      end

      let(:placement_date) { create(:bookings_placement_date) }
      let(:chosen_subject) { create(:bookings_subject) }


      specify 'should be the bookings_placement_date id and own id delimited by an underscore' do
        expect(subject.date_and_subject_id).to eql("#{placement_date.id}_#{chosen_subject.id}")
      end
    end
  end
end
