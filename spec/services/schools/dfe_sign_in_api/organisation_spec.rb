require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::DFESignInAPI::Organisation do
  include_context "logged in DfE user"

  let(:user_uuid) { '123456' }
  let(:current_school_urn) { 987_654 }
  let(:organisations_data) do
    [
      { 'id' => 1, 'urn' => '123456', 'name' => 'School A', 'ukprn' => '111111' },
      { 'id' => 2, 'urn' => '987654', 'name' => 'School B', 'ukprn' => '222222' },
      { 'id' => 3, 'urn' => '789012', 'name' => 'School C', 'ukprn' => '333333' }
    ]
  end
  let(:response) { organisations_data }

  subject { described_class.new(user_uuid, current_school_urn) }

  before do
    allow(subject).to receive(:response).and_return(response)
  end

  describe '#current_organisation' do
    context 'when current school URN matches an organisation' do
      it 'returns the details of the current organisation' do
        expect(subject.current_organisation).to eq({ 'id' => 2, 'urn' => '987654', 'name' => 'School B', 'ukprn' => '222222' })
      end
    end

    context 'when current school URN does not match any organisation' do
      let(:current_school_urn) { 999_999 }

      it 'returns nil' do
        expect(subject.current_organisation).to be_nil
      end
    end
  end

  describe '#current_organisation_ukprn' do
    context 'when current school URN matches an organisation' do
      it 'returns the UKPRN of the current organisation' do
        expect(subject.current_organisation_ukprn).to eq('222222')
      end
    end

    context 'when current school URN does not match any organisation' do
      let(:current_school_urn) { 999_999 }

      it 'returns nil' do
        expect(subject.current_organisation_ukprn).to be_nil
      end
    end
  end

  describe '#current_organisation_id' do
    context 'when current school URN matches an organisation' do
      it 'returns the ID of the current organisation' do
        expect(subject.current_organisation_id).to eq(2)
      end
    end

    context 'when current school URN does not match any organisation' do
      let(:current_school_urn) { 999_999 }

      it 'returns nil' do
        expect(subject.current_organisation_id).to be_nil
      end
    end
  end
end
