require 'rails_helper'

describe Schools::OnBoarding::PreviewPresenter do
  subject { described_class.new profile }

  let! :school do
    FactoryBot.create :bookings_school, :full_address, urn: 123_456
  end

  context '#warning' do
    let :profile do
      FactoryBot.create :school_profile, bookings_school: school
    end

    context 'when school is onboarded' do
      let(:school) do
        FactoryBot.create :bookings_school, :onboarded, :full_address, urn: 123_456
      end

      it 'returns publich warning' do
        expect(subject.warning).to eq "To save your changes, go back and select 'Publish changes'."
      end
    end

    context 'when school is not onboarded' do
      it 'returns profile set up warning' do
        expect(subject.warning).to eq "To set up your profile, go back and select 'Accept and set up profile'."
      end
    end
  end
end
