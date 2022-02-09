require 'rails_helper'

describe Candidates::Registrations::SubjectAndDateInformationHelper do
  include Schools::PlacementDatesHelper

  describe "#format_primary_date_options" do
    let(:output) { format_primary_date_options([option]) }
    let(:option) do
      Candidates::PlacementDateOption.new 3, "01 February 2022", 2, Date.parse("2022-02-01"), true
    end

    subject { output }

    it { is_expected.to have_attributes length: 1 }

    describe "option key" do
      subject { output.first.first }

      it { is_expected.to eql 3 }
    end

    describe "option label" do
      subject { output.first.last }

      it { is_expected.to have_css "span", text: "01 February 2022 (2 days)" }
      it { is_expected.to have_css "p" }
    end
  end
end
