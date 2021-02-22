require "rails_helper"
require "academic_year"

RSpec.describe AcademicYear do
  describe ".start_for_date" do
    context "with a Date object" do
      subject { described_class.start_for_date date }

      context "with date after the new academic year has started" do
        let(:date) { Date.parse("2021-10-12") }
        it { is_expected.to eql Date.parse("2021-09-01").at_beginning_of_day }
      end

      context "with date before the new academic year has started" do
        let(:date) { Date.parse("2021-08-12") }
        it { is_expected.to eql Date.parse("2020-09-01").at_beginning_of_day }
      end
    end

    context "with a Time object" do
      subject { described_class.start_for_date time }

      context "with date after the new academic year has started" do
        let(:time) { Time.zone.parse("2021-10-12") }
        it { is_expected.to eql Date.parse("2021-09-01").at_beginning_of_day }
      end

      context "with date before the new academic year has started" do
        let(:time) { Time.zone.parse("2021-08-12") }
        it { is_expected.to eql Date.parse("2020-09-01").at_beginning_of_day }
      end
    end
  end
end
