require 'rails_helper'

describe Schools::CsvForm, type: :model do

  context "attributes" do
    it { is_expected.to respond_to :from_date }
    it { is_expected.to respond_to :to_date }
  end

  context "validation" do
    it { is_expected.to validate_presence_of(:from_date) }
    it { is_expected.to validate_presence_of(:to_date) }

    context "when from_date is 5/2/2020" do
      before { subject.from_date = Date.new(2020, 2, 5) }

      it { is_expected.to allow_value(subject.from_date).for :to_date }
      it { is_expected.not_to allow_value(Date.new(2020, 2, 1)).for :to_date }
    end
  end

  describe "#dates_range" do
    subject { described_class.new(from_date: Date.yesterday, to_date: Date.today).dates_range }

    it "returns the range using beginning_of_day and end_of_day" do
      expect(subject).to eq (Date.yesterday.beginning_of_day..Date.today.end_of_day)
    end
  end

  context "when not valid" do
    subject { described_class.new }

    it "should not be valid" do
      expect(subject).not_to be_valid
    end

    it "should have errors" do
      subject.valid?
      expect(subject.errors.messages[:from_date]).to include "You must specify a start date"
      expect(subject.errors.messages[:to_date]).to include "You must specify an end date"
    end
  end
end
