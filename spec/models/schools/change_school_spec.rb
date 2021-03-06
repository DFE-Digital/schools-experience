require 'rails_helper'

describe Schools::ChangeSchool, type: :model do
  subject { change_school }

  let(:first_school) { create(:bookings_school) }
  let(:second_school) { create(:bookings_school) }
  let(:user_uuid) { SecureRandom.uuid }
  let(:user) { Struct.new(:sub).new(user_uuid) }
  let(:change_to_urn) { nil }
  let(:user_has_role) { true }

  let(:uuid_map) do
    {
      SecureRandom.uuid => first_school.urn,
      SecureRandom.uuid => second_school.urn,
      SecureRandom.uuid => 1_000_000
    }
  end

  let(:change_school) do
    described_class.new user, uuid_map, change_to_urn: change_to_urn
  end

  before do
    allow(Schools::DFESignInAPI::Roles).to \
      receive(:new).and_call_original

    allow_any_instance_of(Schools::DFESignInAPI::Roles).to \
      receive(:has_school_experience_role?) { user_has_role }
  end

  describe 'attributes' do
    it { is_expected.to respond_to :change_to_urn }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :change_to_urn }
    it { is_expected.to validate_inclusion_of(:change_to_urn).in_array uuid_map.values }
  end

  describe '#available_schools' do
    it 'should only return schools which we have in our system' do
      is_expected.to have_attributes \
        available_schools: match_array([first_school, second_school])
    end
  end

  describe '#school_uuid' do
    let(:change_to_urn) { second_school.urn }
    it { is_expected.to have_attributes school_uuid: uuid_map.keys[1] }
  end

  describe '#user_uuid' do
    it { is_expected.to have_attributes user_uuid: user_uuid }
  end

  describe '#retrieve_valid_school!' do
    subject { change_school.retrieve_valid_school! }

    let(:change_to_urn) { second_school.urn }

    context 'with unknown urn' do
      let(:change_to_urn) { 20_000 }

      it { expect { subject }.to raise_exception ActiveModel::ValidationError }
    end

    context 'with valid urn' do
      it 'should return school' do
        is_expected.to eql second_school
      end
    end

    context 'with urn not in allow schools list' do
      let(:uuid_map) { { SecureRandom.uuid => first_school.urn } }

      it { expect { subject }.to raise_exception ActiveModel::ValidationError }
    end
  end
end
