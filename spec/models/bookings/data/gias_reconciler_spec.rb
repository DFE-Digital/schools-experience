require "rails_helper"

describe Bookings::Data::GiasReconciler do
  let(:instance) { described_class.new }

  before do
    temp_csv = Tempfile.new
    temp_csv.write(csv)
    temp_csv.close
    data_file = instance_double(Bookings::Data::GiasDataFile, path: temp_csv.path)
    allow(Bookings::Data::GiasDataFile).to receive(:new).and_return(data_file)
  end

  describe "#identify_onboarded_closed" do
    subject { instance.identify_onboarded_closed }

    let(:onboarded_school) { create(:bookings_school, :onboarded) }
    let(:onboarded_disabled_school) { create(:bookings_school, :onboarded, :disabled) }
    let(:open_school_one) { create(:bookings_school) }
    let(:open_school_two) { create(:bookings_school) }
    let(:csv) do
      <<~CSV
        URN,CloseDate
        #{onboarded_school.urn},#{2.days.ago}
        #{onboarded_disabled_school.urn},#{2.months.ago}
        #{open_school_one.urn},
        #{open_school_two.urn},
      CSV
    end


    it { is_expected.to contain_exactly(onboarded_school, onboarded_disabled_school) }
  end

  describe "#find_reopened_urns" do
    subject { instance.find_reopened_urns([first_closed_school.urn]) }

    let(:first_closed_school) { create(:bookings_school) }
    let(:second_closed_school) { create(:bookings_school) }
    let(:third_closed_school) { create(:bookings_school) }
    let(:first_reopened_school) { create(:bookings_school) }
    let(:second_reopened_school) { create(:bookings_school) }
    let(:csv) do
      <<~CSV
        URN,CloseDate,LA (code),EstablishmentNumber,LA (name)
        #{first_closed_school.urn},#{1.month.ago},888,1572,Hillend Primary
        #{second_closed_school.urn},#{1.day.ago},888,1572,Hillend Primary
        #{first_reopened_school.urn},,888,1572,Hillend Primary
        #{second_reopened_school.urn},,888,1572,Hillend Primary
        #{third_closed_school.urn},#{2.days.ago},999,1984,Main St Secondary
      CSV
    end


    it { is_expected.to eq({ first_closed_school.urn => [first_reopened_school.urn, second_reopened_school.urn] }) }
  end
end
