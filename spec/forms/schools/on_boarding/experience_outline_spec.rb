require 'rails_helper'

describe Schools::OnBoarding::ExperienceOutline, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :candidate_experience }
  end

  context '.new_from_bookings_school' do
    let :school do
      FactoryBot.build \
        :bookings_school,
        :with_placement_info
    end

    subject { described_class.new_from_bookings_school school }

    it "sets candidate_experience to the school's placement_info" do
      expect(subject.candidate_experience).to eq school.placement_info
    end
  end
end
