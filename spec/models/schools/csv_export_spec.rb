require "rails_helper"

RSpec.describe Schools::CsvExport do
  let(:dates_range) { (Date.yesterday.beginning_of_day..Date.today.end_of_day) }

  describe ".column" do
    described_class::HEADER.each_with_index do |col, index|
      context "with #{col}" do
        subject { described_class.column(col) }

        it { is_expected.to eql index }
      end
    end
  end

  describe "#filename" do
    subject { described_class.new(school, dates_range).filename }

    let(:school) { create :bookings_school }
    let(:urn) { school.urn }
    let(:today) { Time.zone.today.to_formatted_s(:govuk) }

    it { is_expected.to eql "School experience export (#{urn}) - #{today}.csv" }
  end

  describe "#export" do
    subject { parsed_csv }

    let(:school) { create :bookings_school }
    let(:generated_csv) { described_class.new(school, dates_range).export }
    let(:parsed_csv) { CSV.new(generated_csv).read }

    describe "header rows" do
      subject { parsed_csv[0] }

      it "should contain a header row" do
        is_expected.to eql \
          ["Id", "Name", "Email", "Date", "Duration", "Subject", "Second Subject", "Status", "Attendance"]
      end
    end

    describe "data rows" do
      include_context "api sign ups for requests"

      subject { parsed_csv.slice(1...).map(&:first).map(&:to_i) }

      let(:first) { create(:bookings_booking).bookings_placement_request }
      let(:school) { first.school }
      let(:second) { create :bookings_placement_request, school: school }
      let!(:historical) do
        create :bookings_placement_request, school: school, created_at: 1.year.ago
      end
      let(:requests) { [first, second] }

      it "should contain placement requests from this academic year" do
        is_expected.to eql [first.id, second.id]
      end

      it "should not contain placement requests from earlier academic years" do
        is_expected.not_to include historical.id
      end

      context "crm data" do
        subject { parsed_csv.slice(1...).map(&:second) }

        it { is_expected.to eql sign_ups.map(&:full_name) }
      end
    end
  end
end
