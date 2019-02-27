require 'rails_helper'

describe Candidates::Registrations::PrivacyPolicy, type: :model do
  context 'attributes' do
    it { is_expected.to respond_to :acceptance }
  end

  context 'validations' do
    it { is_expected.to validate_acceptance_of :acceptance }
  end
end
