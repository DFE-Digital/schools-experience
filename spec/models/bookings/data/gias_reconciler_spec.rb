require "rails_helper"

describe Bookings::Data::GiasReconciler do
  let(:instance) { described_class.new }

  before do
    temp_csv = Tempfile.new
    temp_csv.write(csv)
    temp_csv.close
    allow_any_instance_of(Bookings::Data::GiasDataFile).to receive(:path) { temp_csv.path }
  end

  describe "#identify_onboarded_closed" do
    let(:onboarded_school) { create(:bookings_school, :onboarded) }
    let(:onboarded_disabled_school) { create(:bookings_school, :onboarded, :disabled) }
    let(:school_1) { create(:bookings_school) }
    let(:school_2) { create(:bookings_school) }
    let(:csv) do
      <<~CSV
        URN,CloseDate
        #{onboarded_school.urn},#{2.days.ago}
        #{onboarded_disabled_school.urn},#{2.months.ago}
        #{school_1.urn},
        #{school_2.urn},
      CSV
    end

    subject { instance.identify_onboarded_closed }

    it { is_expected.to contain_exactly(onboarded_school, onboarded_disabled_school) }
  end

  describe "#find_reopened_urns" do
    let(:closed_school_1) { create(:bookings_school) }
    let(:closed_school_2) { create(:bookings_school) }
    let(:closed_school_3) { create(:bookings_school) }
    let(:reopened_school_1) { create(:bookings_school) }
    let(:reopened_school_2) { create(:bookings_school) }
    let(:csv) do
      <<~CSV
        URN,CloseDate,LA (code),EstablishmentNumber,LA (name)
        #{closed_school_1.urn},#{1.month.ago},888,1572,Hillend Primary
        #{closed_school_2.urn},#{1.day.ago},888,1572,Hillend Primary
        #{reopened_school_1.urn},,888,1572,Hillend Primary
        #{reopened_school_2.urn},,888,1572,Hillend Primary
        #{closed_school_3.urn},#{2.days.ago},999,1984,Main St Secondary
      CSV
    end

    subject { instance.find_reopened_urns([closed_school_1.urn]) }

    it { is_expected.to eq({ closed_school_1.urn => [reopened_school_1.urn, reopened_school_2.urn] }) }
  end
end
