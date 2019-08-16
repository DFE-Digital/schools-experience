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

  describe '#contact' do
    before do
      allow(fake_gitis).to receive(:find).and_call_original
    end

    let(:servicemodel) { described_class.new(fake_gitis, contact.id, policy_id) }
    subject! { servicemodel.contact }

    it { is_expected.to be_kind_of Bookings::Gitis::Contact }
    it { is_expected.to have_attributes(contactid: contact.id) }

    it "will also retrieve accepted policies" do
      expect(fake_gitis).to \
        have_received(:find).with contact.id, hash_including(
          includes: :dfe_contact_dfe_candidateprivacypolicy_Candidate
        )
    end
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
    context 'without existing acceptance' do
      before do
        allow(fake_gitis.store).to \
          receive(:create_entity).
          and_return("#{cpp_entity_path}(#{candidate_pp_id})")

        freeze_time
      end

      subject! { described_class.new(fake_gitis, contact.id, policy_id).accept! }

      it "will write to gitis" do
        expect(fake_gitis.store).to have_received(:create_entity).with \
          cpp_entity_path,
          'dfe_name' => /school experience/,
          'dfe_consentreceivedby' => consent_id,
          'dfe_meanofconsent' => consent_id,
          'dfe_timeofconsent' => Time.now.utc.iso8601,
          'dfe_Candidate@odata.bind' => contact.entity_id,
          'dfe_PrivacyPolicyNumber@odata.bind' => "#{pp_entity_path}(#{policy_id})"
      end
    end

    context 'with existing acceptance' do
      let(:policy_data) do
        {
          'dfe_candidateprivacypolicyid' => candidate_pp_id,
          'dfe_name' => 'Privacy Policy v9',
          'dfe_consentreceivedby' => consent_id,
          'dfe_meanofconsent' => consent_id,
          'dfe_timeofconsent' => Time.now.utc.iso8601,
          '_dfe_privacypolicynumber_value' => policy_id
        }
      end

      let(:contact) do
        build :gitis_contact, :persisted,
          dfe_contact_dfe_candidateprivacypolicy_Candidate: [policy_data]
      end

      before do
        allow(fake_gitis).to \
          receive(:find).
          with(contact.id, includes: :dfe_contact_dfe_candidateprivacypolicy_Candidate).
          and_return(contact)

        allow(fake_gitis.store).to receive(:create_entity).and_call_original

        freeze_time
      end

      subject! { described_class.new(fake_gitis, contact.id, policy_id).accept! }

      it "will return id of existing policy" do
        is_expected.to be candidate_pp_id
      end

      it "will write to gitis" do
        expect(fake_gitis.store).not_to have_received(:create_entity)
      end
    end
  end
end
