require 'rails_helper'

describe Schools::PlacementDatesHelper, type: 'helper' do
  describe '#placement_date_subject_description' do
    subject { placement_date_subject_description(pd) }

    context 'when the placement date is subject specific' do
      let(:subjects) { Bookings::Subject.where(name: %w[Biology Maths]) }
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

  describe "#placement_date_virtual_tag" do
    subject { placement_date_virtual_tag }

    it { is_expected.to have_css "p", text: "Virtual" }
  end

  describe "#placement_date_inschool_tag" do
    subject { placement_date_inschool_tag }

    it { is_expected.to have_css "p", text: "In school" }
  end

  describe "#placement_date_experience_type_tag" do
    subject { placement_date_experience_type_tag virtual }

    context "with a virtual date" do
      let(:virtual) { true }

      it { is_expected.to have_css "p", text: "Virtual" }
    end

    context "with an in school date" do
      let(:virtual) { false }

      it { is_expected.to have_css "p", text: "In school" }
    end
  end

  describe "#placement_date_phase" do
    subject { placement_date_phase(placement_date) }

    context "when supports_subjects is true" do
      let(:placement_date) { double(Bookings::PlacementDate, supports_subjects: true) }

      it { is_expected.to eq("Secondary") }
    end

    context "when supports_subjects is false" do
      let(:placement_date) { double(Bookings::PlacementDate, supports_subjects: false) }

      it { is_expected.to eq("Primary") }
    end
  end

  describe "#placement_date_anchor" do
    subject { placement_date_anchor(placement_date) }

    context "when supports_subjects is true" do
      let(:placement_date) { double(Bookings::PlacementDate, supports_subjects: true, date: Date.new(2021, 1, 2)) }

      it { is_expected.to eq("secondary-placement-date-2021-01-02") }
    end

    context "when supports_subjects is false" do
      let(:placement_date) { double(Bookings::PlacementDate, supports_subjects: false, date: Date.new(2021, 3, 4)) }

      it { is_expected.to eq("primary-placement-date-2021-03-04") }
    end
  end
end
