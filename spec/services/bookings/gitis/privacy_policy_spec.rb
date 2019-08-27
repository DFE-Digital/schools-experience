require 'rails_helper'

RSpec.describe Bookings::Gitis::PrivacyPolicy, type: :model do
  let(:uuid) { SecureRandom.uuid }

  describe '.entity_path' do
    subject { described_class.entity_path }
    it { is_expected.to eq('dfe_privacypolicies') }
  end

  describe '.primary_key' do
    subject { described_class.primary_key }
    it { is_expected.to eq('dfe_privacypolicyid') }
  end

  describe 'attributes' do
    it { is_expected.to respond_to :dfe_name }
    it { is_expected.to respond_to :dfe_privacypolicyid }
    it { is_expected.to respond_to :dfe_policyid }
    it { is_expected.to respond_to :dfe_active }
  end

  describe '.new' do
    subject do
      described_class.new(
        'dfe_privacypolicyid' => uuid,
        'dfe_policyid' => 1,
        'dfe_active' => true,
        'dfe_name' => 'Test Policy'
      )
    end

    it { is_expected.to have_attributes(dfe_privacypolicyid: uuid) }
    it { is_expected.to have_attributes(dfe_policyid: 1) }
    it { is_expected.to have_attributes(dfe_name: 'Test Policy') }
    it { is_expected.to have_attributes(dfe_active: true) }
    it { is_expected.to have_attributes(changed_attributes: {}) }
  end
end
