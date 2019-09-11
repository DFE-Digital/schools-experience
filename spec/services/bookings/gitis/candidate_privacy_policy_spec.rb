require 'rails_helper'

RSpec.describe Bookings::Gitis::CandidatePrivacyPolicy, type: :model do
  let(:uuid) { SecureRandom.uuid }

  describe '.entity_path' do
    subject { described_class.entity_path }
    it { is_expected.to eq('dfe_candidateprivacypolicies') }
  end

  describe '.primary_key' do
    subject { described_class.primary_key }
    it { is_expected.to eq('dfe_candidateprivacypolicyid') }
  end

  describe 'attributes' do
    it { is_expected.to respond_to :dfe_candidateprivacypolicyid }
    it { is_expected.to respond_to :dfe_name }
    it { is_expected.to respond_to :dfe_consentreceivedby }
    it { is_expected.to respond_to :dfe_meanofconsent }
    it { is_expected.to respond_to :dfe_timeofconsent }
    it { is_expected.to respond_to :'dfe_Candidate@odata.bind' }
    it { is_expected.to respond_to :_dfe_candidate_value }
    it { is_expected.to respond_to :'dfe_PrivacyPolicyNumber@odata.bind' }
    it { is_expected.to respond_to :_dfe_privacypolicynumber_value }
  end

  describe '.new' do
    let(:candidate_uuid) { SecureRandom.uuid }
    let(:privacypolicy_uuid) { SecureRandom.uuid }

    subject do
      described_class.new(
        'dfe_candidateprivacypolicyid' => uuid,
        'dfe_name' => "school experience",
        'dfe_consentreceivedby' => '100',
        'dfe_meanofconsent' => '100',
        'dfe_timeofconsent' => Time.now.utc.iso8601,
        '_dfe_candidate_value' => candidate_uuid,
        '_dfe_privacypolicynumber_value' => privacypolicy_uuid
      )
    end

    it { is_expected.to have_attributes(dfe_candidateprivacypolicyid: uuid) }
    it { is_expected.to have_attributes(dfe_name: 'school experience') }
    it { is_expected.to have_attributes(dfe_consentreceivedby: '100') }
    it { is_expected.to have_attributes(dfe_meanofconsent: '100') }
    it { is_expected.to have_attributes(dfe_timeofconsent: Time.now.utc.iso8601) }
    it { is_expected.to have_attributes(_dfe_candidate_value: candidate_uuid) }
    it { is_expected.to have_attributes(_dfe_privacypolicynumber_value: privacypolicy_uuid) }
    it { is_expected.to have_attributes(changed_attributes: {}) }
  end
end
