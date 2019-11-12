require 'rails_helper'

describe Schools::PlacementDatesHelper, type: 'helper' do
  subject { placement_date_subject_description(pd) }

  describe '#placement_date_subject_description' do
    context 'when the placement date is subject specific' do
      let(:subjects) { Bookings::Subject.where(name: %w(Biology Maths)) }
      let(:pd) { double(Bookings::PlacementDate, subjects: subjects, subject_specific?: true) }

      specify 'should return the subjects list' do
        expect(subject).to eql('Biology, Maths')
      end
    end

    context 'when the placement date supports subjects' do
      let(:pd) { double(Bookings::PlacementDate, subject_specific?: false, supports_subjects?: true) }

      specify "should return 'All subjects'" do
        expect(subject).to eql('All subjects')
      end
    end

    context "when the placement date doesn't support subjects" do
      let(:pd) { double(Bookings::PlacementDate, subject_specific?: false, supports_subjects?: false) }

      specify "should return 'Primary'" do
        expect(subject).to eql('Primary')
      end
    end
  end
end
