require 'rails_helper'

describe Bookings::Gitis::AcceptPrivacyPolicy do
  include ActiveSupport::Testing::TimeHelpers
  include_context 'fake gitis'
  let(:contact) { build(:gitis_contact, :persisted) }
  let(:policy_id) { SecureRandom.uuid }
  let(:candidate_pp_id) { SecureRandom.uuid }
  let(:consent_id) { Bookings::Gitis::PrivacyPolicy.consent }
  let(:cpp_entity_path) { Bookings::Gitis::CandidatePrivacyPolicy.entity_path }
  let(:pp_entity_path) { Bookings::Gitis::PrivacyPolicy.entity_path }

  describe '.new' do
    subject { described_class.new(fake_gitis, contact.id, policy_id) }
    it { is_expected.to be_kind_of Bookings::Gitis::AcceptPrivacyPolicy }
    it { is_expected.to have_attributes(contact_id: contact.id) }
    it { is_expected.to have_attributes(policy_id: policy_id) }
  end

  describe '#build' do
    before { freeze_time }

    subject do
      described_class.new(fake_gitis, contact.id, policy_id).send(:build)
    end

    it { is_expected.to have_attributes(dfe_candidateprivacypolicyid: nil) }
    it { is_expected.to have_attributes(dfe_name: /school experience/) }
    it { is_expected.to have_attributes(dfe_consentreceivedby: consent_id) }
    it { is_expected.to have_attributes(dfe_meanofconsent: consent_id) }
    it { is_expected.to have_attributes(dfe_timeofconsent: Time.now.utc.iso8601) }
    it { is_expected.to have_attributes(_dfe_candidate_value: contact.id) }
    it { is_expected.to have_attributes(_dfe_privacypolicynumber_value: policy_id) }
  end

  describe '#accept!' do
    before do
      allow(fake_gitis).to \
        receive(:create_entity).
        and_return("#{cpp_entity_path}(#{candidate_pp_id})")

      freeze_time
    end

    subject! { described_class.new(fake_gitis, contact.id, policy_id).accept! }

    it "will write to gitis" do
      expect(fake_gitis).to have_received(:create_entity).with \
        cpp_entity_path,
        'dfe_name' => /school experience/,
        'dfe_consentreceivedby' => consent_id,
        'dfe_meanofconsent' => consent_id,
        'dfe_timeofconsent' => Time.now.utc.iso8601,
        'dfe_Candidate@odata.bind' => contact.entity_id,
        'dfe_PrivacyPolicyNumber@odata.bind' => "#{pp_entity_path}(#{policy_id})"
    end
  end
end
