require 'rails_helper'

describe Schools::ChangeSchool, type: :model do
  let(:first_school) { create(:bookings_school) }
  let(:second_school) { create(:bookings_school) }
  let(:user_uuid) { SecureRandom.uuid }
  let(:user) { Struct.new(:sub).new(user_uuid) }
  let(:current_urn) { nil }
  let(:user_has_role) { true }
  let(:uuid_map) do
    {
      SecureRandom.uuid => first_school.urn,
      SecureRandom.uuid => second_school.urn,
      SecureRandom.uuid => 1000000
    }
  end

  before do
    allow(Schools::DFESignInAPI::Roles).to \
      receive(:new).and_call_original

    allow_any_instance_of(Schools::DFESignInAPI::Roles).to \
      receive(:has_school_experience_role?) { user_has_role }
  end

  subject { described_class.new(user, uuid_map, urn: current_urn) }

  describe 'attributes' do
    it { is_expected.to respond_to :urn }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :urn }
    it { is_expected.to validate_inclusion_of(:urn).in_array uuid_map.values }
  end

  describe '#available_schools' do
    it 'should only return schools which we have in our system' do
      is_expected.to have_attributes \
        available_schools: match_array([first_school, second_school])
    end
  end

  describe '#school_uuid' do
    let(:current_urn) { second_school.urn }
    it { is_expected.to have_attributes school_uuid: uuid_map.keys[1] }
  end

  describe '#user_uuid' do
    it { is_expected.to have_attributes user_uuid: user_uuid }
  end

  describe '#retrieve_valid_school!' do
    let(:current_urn) { second_school.urn }

    context 'with unknown urn' do
      let(:current_urn) { 20000 }

      it 'will raise exception' do
        expect { subject.retrieve_valid_school! }.to \
          raise_exception(ActiveModel::ValidationError)
      end
    end

    context 'with valid urn and passing role check' do
      before { subject.retrieve_valid_school! }

      it 'should call role api' do
        expect(Schools::DFESignInAPI::Roles).to \
          have_received(:new).with(user_uuid, uuid_map.keys[1])
      end
    end

    context 'wth valid urn and failing role check' do
      let(:user_has_role) { false }

      it 'should call role api and raise exception' do
        expect { subject.retrieve_valid_school! }.to \
          raise_exception(ActiveModel::ValidationError)

        expect(Schools::DFESignInAPI::Roles).to \
          have_received(:new).with(user_uuid, uuid_map.keys[1])
      end
    end
  end
end
