require "rails_helper"

describe Schools::PlacementDates::ReviewRecurrences, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:dates) }
  end

  describe "#dates" do
    it "converts the dates to a Date type" do
      subject.dates = %w[2021-01-01]

      expect(subject.dates.first).to eq(Date.new(2021, 1, 1))
    end
  end
end
