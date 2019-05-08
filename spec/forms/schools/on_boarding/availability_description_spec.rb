require 'rails_helper'

describe Schools::OnBoarding::AvailabilityDescription, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :description }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :description }
  end

  context '.new_from_bookings_school' do
    let :school do
      FactoryBot.build :bookings_school, :with_availability_info
    end

    subject { described_class.new_from_bookings_school school }

    it 'sets the availabilty description from the bookings_school' do
      expect(subject.description).to eq school.availability_info
    end
  end
end
