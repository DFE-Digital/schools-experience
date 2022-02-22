require 'rails_helper'

describe Schools::OnBoarding::CandidateParkingInformation, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :parking_provided }
    it { is_expected.to respond_to :parking_details }
    it { is_expected.to respond_to :nearby_parking_details }
  end

  context 'validations' do
    it { is_expected.not_to allow_value(nil).for :parking_provided }

    context 'when parking_provided' do
      subject { described_class.new parking_provided: true }
      it { is_expected.to validate_presence_of :parking_details }
      it { is_expected.not_to validate_presence_of :nearby_parking_details }
    end

    context 'when not parking_provided' do
      subject { described_class.new parking_provided: false }
      it { is_expected.not_to validate_presence_of :parking_details }
      it { is_expected.to validate_presence_of :nearby_parking_details }
    end
  end
end
