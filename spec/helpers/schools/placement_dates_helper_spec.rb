require 'rails_helper'

describe Schools::PlacementDatesHelper, type: 'helper' do
  describe '#placement_date_status_tag' do
    subject { placement_date_status_tag(placement_date) }

    context "when placement date is available (inside availability window)" do
      let(:placement_date) { create(:bookings_placement_date, :active) }

      it { is_expected.to have_css "strong", text: "Open", class: "govuk-tag govuk-tag--available" }
    end

    context "when placement date is active but not available" do
      let(:placement_date) { create(:bookings_placement_date, :active, :outside_availability_window) }

      it { is_expected.to have_css "strong", text: "Scheduled", class: "govuk-tag govuk-tag--grey" }
    end

    context "when placement date is active and end of availability is not in the future" do
      let(:placement_date) { create(:bookings_placement_date, :active, date: Date.tomorrow, end_availability_offset: 1) }

      it { is_expected.to have_css "strong", text: "Closed", class: "govuk-tag govuk-tag--taken" }
    end

    context "when placement date is inactive" do
      let(:placement_date) { create(:bookings_placement_date, :inactive) }

      it { is_expected.to have_css "strong", text: "Closed", class: "govuk-tag govuk-tag--taken" }
    end
  end

  describe "#start_availability_offset_label" do
    it { expect(start_availability_offset_label(false)).to eq("When do you want to publish this date?") }
    it { expect(start_availability_offset_label(true)).to eq("When do you want to publish these dates?") }
  end

  describe "#end_availability_offset_label" do
    it { expect(end_availability_offset_label(false)).to eq("When do you want to close this date to candidates?") }
    it { expect(end_availability_offset_label(true)).to eq("When do you want to close these dates to candidates?") }
  end

  describe "#duration_label" do
    it { expect(duration_label(false)).to eq("How long will it last?") }
    it { expect(duration_label(true)).to eq("How long will they last?") }
  end

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

    it { is_expected.to have_css "strong", text: "Virtual" }
  end

  describe "#placement_date_inschool_tag" do
    subject { placement_date_inschool_tag }

    it { is_expected.to have_css "strong", text: "In school" }
  end

  describe "#placement_date_experience_type_tag" do
    subject { placement_date_experience_type_tag virtual }

    context "with a virtual date" do
      let(:virtual) { true }

      it { is_expected.to have_css "strong", text: "Virtual" }
    end

    context "with an in school date" do
      let(:virtual) { false }

      it { is_expected.to have_css "strong", text: "In school" }
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

  describe "#close_date_link" do
    subject { close_date_link(placement_date) }

    context "when date is available" do
      let(:placement_date) { create :bookings_placement_date, :active }

      it "returns a link to the close date page" do
        expect(subject).to eq link_to("Close", schools_placement_date_close_path(placement_date.id))
      end
    end

    context "when date is not available" do
      let(:placement_date) { create :bookings_placement_date, active: false }

      it "returns nil" do
        expect(subject).to be_nil
      end
    end
  end
end
