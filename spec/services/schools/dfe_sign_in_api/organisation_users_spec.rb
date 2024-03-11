require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::DFESignInAPI::OrganisationUsers do
  let(:user_uuid) { '123456' }
  let(:current_school_urn) { '987654' }
  let(:ukprn) { 'organisation-ukprn-id' }
  let(:response) do
    {
      'ukprn' => ukprn,
      'users' => [
        {
          'email' => 'user1@test.com',
          'firstName' => 'user1',
          'lastName' => 'test',
          'userStatus' => 1,
          'roles' => %w[role1]
        },
        {
          'email' => 'user21@test.com',
          'firstName' => 'user2',
          'lastName' => 'test',
          'roles' => %w[role1 role2]
        }
      ]
    }
  end

  subject { described_class.new(user_uuid, current_school_urn) }

  before do
    allow(subject).to receive(:response).and_return(response)
    allow_any_instance_of(Schools::DFESignInAPI::Organisation).to receive(:current_organisation_ukprn).and_return(ukprn)
  end

  describe '#initialize' do
    it 'sets user_uuid' do
      expect(subject.user_uuid).to eq(user_uuid)
    end

    it 'sets current_school_urn' do
      expect(subject.current_school_urn).to eq(current_school_urn)
    end
  end

  describe '#ukprn' do
    it 'calls current_organisation_ukprn on Organisation' do
      expect_any_instance_of(Schools::DFESignInAPI::Organisation).to receive(:current_organisation_ukprn).and_return(ukprn)
      expect(subject.ukprn).to eq(ukprn)
    end
  end

  describe '#users' do
    context 'when valid response is received' do
      it 'returns the users from the response' do
        expect(subject.users).to eq(response['users'])
      end
    end

    context 'when response is nil' do
      let(:response) { nil }

      it 'returns nil' do
        expect(subject.users).to be_nil
      end
    end

    context 'when response does not contain users' do
      let(:response) { { 'ukprn' => ukprn } }

      it 'returns an empty array' do
        expect(subject.users).to eq(nil)
      end
    end
  end
end
