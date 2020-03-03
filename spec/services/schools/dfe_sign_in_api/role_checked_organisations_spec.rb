require 'rails_helper'

describe Schools::DFESignInAPI::RoleCheckedOrganisations, type: :model do
  let(:user_uuid) { SecureRandom.uuid }
  let(:org1) { SecureRandom.uuid }
  let(:org2) { SecureRandom.uuid }
  let(:org3) { SecureRandom.uuid }
  let(:org4) { SecureRandom.uuid }
  let(:uuidmap) { { org1 => 1, org2 => 2, org3 => 3, org4 => 4 } }
  let(:orgcheck) { Schools::DFESignInAPI::Organisations }
  let(:rolecheck) { Schools::DFESignInAPI::Roles }

  before do
    allow(orgcheck).to receive(:new) { double(orgcheck, uuids: uuidmap) }

    allow(rolecheck).to receive(:new) \
      { double(rolecheck, has_school_experience_role?: false) }

    allow(rolecheck).to receive(:new).with(user_uuid, org1) \
      { double(rolecheck, has_school_experience_role?: true) }

    allow(rolecheck).to receive(:new).with(user_uuid, org3) \
      { double(rolecheck, has_school_experience_role?: true) }
  end

  subject { described_class.new(user_uuid) }

  describe '#organisation_uuid_pairs' do
    it "should only include uuids the user has a role over" do
      is_expected.to have_attributes \
        organisation_uuid_pairs: { org1 => 1, org3 => 3 }
    end
  end

  describe '#organisation_uuids' do
    it { is_expected.to have_attributes organisation_uuids: [org1, org3] }
  end

  describe '#organisation_urns' do
    it { is_expected.to have_attributes organisation_urns: [1, 3] }
  end
end
