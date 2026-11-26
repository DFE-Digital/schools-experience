require 'rails_helper'

describe Schools::DFESignInAPI::RoleCheckedOrganisations, type: :model do
  subject { described_class.new(user_uuid) }

  let(:user_uuid) { SecureRandom.uuid }
  let(:organisation_uuid_one) { SecureRandom.uuid }
  let(:organisation_uuid_two) { SecureRandom.uuid }
  let(:organisation_uuid_three) { SecureRandom.uuid }
  let(:organisation_uuid_four) { SecureRandom.uuid }
  let(:uuidmap) { { organisation_uuid_one => 1, organisation_uuid_two => 2, organisation_uuid_three => 3, organisation_uuid_four => 4 } }
  let(:orgcheck) { Schools::DFESignInAPI::Organisations }
  let(:rolecheck) { Schools::DFESignInAPI::Roles }

  before do
    allow(Schools::DFESignInAPI::Client).to receive(:role_check_enabled?).and_return(true)

    allow(orgcheck).to receive(:new) { instance_double(orgcheck, uuids: uuidmap) }

    allow(rolecheck).to receive(:new) \
      { instance_double(rolecheck, has_school_experience_role?: false) }

    allow(rolecheck).to receive(:new).with(user_uuid, organisation_uuid_one) \
      { instance_double(rolecheck, has_school_experience_role?: true) }

    allow(rolecheck).to receive(:new).with(user_uuid, organisation_uuid_three) \
      { instance_double(rolecheck, has_school_experience_role?: true) }
  end

  describe '#organisation_uuid_pairs' do
    it "onlies include uuids the user has a role over" do
      expect(subject).to have_attributes \
        organisation_uuid_pairs: { organisation_uuid_one => 1, organisation_uuid_three => 3 }
    end
  end

  describe '#organisation_uuids' do
    it { is_expected.to have_attributes organisation_uuids: [organisation_uuid_one, organisation_uuid_three] }
  end

  describe '#organisation_urns' do
    it { is_expected.to have_attributes organisation_urns: [1, 3] }
  end

  context "when role check is disabled" do
    before { allow(Schools::DFESignInAPI::Client).to receive(:role_check_enabled?).and_return(false) }

    describe '#organisation_uuid_pairs' do
      it "includes all uuids" do
        expect(subject).to have_attributes \
          organisation_uuid_pairs: { organisation_uuid_one => 1, organisation_uuid_two => 2, organisation_uuid_three => 3, organisation_uuid_four => 4 }
      end
    end

    describe '#organisation_uuids' do
      it { is_expected.to have_attributes organisation_uuids: [organisation_uuid_one, organisation_uuid_two, organisation_uuid_three, organisation_uuid_four] }
    end

    describe '#organisation_urns' do
      it { is_expected.to have_attributes organisation_urns: [1, 2, 3, 4] }
    end
  end
end
