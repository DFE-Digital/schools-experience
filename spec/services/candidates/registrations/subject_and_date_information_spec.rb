require 'rails_helper'

describe Candidates::Registrations::SubjectAndDateInformation, type: :model do
  it_behaves_like 'a registration step' do
    include_context 'Stubbed candidates school', fixed: true
  end

  context 'attributes' do
    it { is_expected.to respond_to :availability }
    it { is_expected.to respond_to :bookings_placement_date_id }
    it { is_expected.to respond_to :school }
    it { is_expected.to respond_to :subject_id }
  end

  context 'validations' do
    context 'when the associated school has fixed availability' do
      before { subject.school = create(:bookings_school, :with_fixed_availability_preference) }
      it { is_expected.to validate_presence_of(:bookings_placement_date_id) }
    end
  end
end
