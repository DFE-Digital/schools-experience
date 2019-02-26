require 'rails_helper'

describe Candidates::Registrations::ContactInformation, type: :model do
  it_behaves_like 'a registration step'

  context 'attributes' do
    it { is_expected.to respond_to :full_name }
    it { is_expected.to respond_to :email }
    it { is_expected.to respond_to :building }
    it { is_expected.to respond_to :street }
    it { is_expected.to respond_to :town_or_city }
    it { is_expected.to respond_to :county }
    it { is_expected.to respond_to :postcode }
    it { is_expected.to respond_to :phone }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :full_name }
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_presence_of :building }
    it { is_expected.to validate_presence_of :street }
    it { is_expected.to validate_presence_of :town_or_city }
    it { is_expected.to validate_presence_of :county }
    it { is_expected.to validate_presence_of :postcode }
    it { is_expected.to validate_presence_of :phone }
  end
end
