require 'rails_helper'
require Rails.root.join("spec", "controllers", "schools", "session_context")

describe Schools::DFESignInAPI::UserInvite, type: :model do
  let(:user_invite) { described_class.new }

  describe 'attributes' do
    it { is_expected.to respond_to(:email) }
    it { is_expected.to respond_to(:firstname) }
    it { is_expected.to respond_to(:lastname) }
    it { is_expected.to respond_to(:organisation_id) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:firstname) }
    it { is_expected.to validate_presence_of(:lastname) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_length_of(:firstname).is_at_most(50) }
    it { is_expected.to validate_length_of(:lastname).is_at_most(50) }
    it { is_expected.to validate_length_of(:email).is_at_most(100) }
    it { is_expected.to allow_value('valid@email.com').for(:email) }
    it { is_expected.not_to allow_value('invalid_email').for(:email) }
    it { is_expected.to validate_presence_of(:organisation_id) }
  end

  describe '#create' do
    context 'when API is enabled' do
      it 'makes a POST request to the API endpoint' do
        expect(user_invite).to receive(:response)
        user_invite.create
      end
    end

    context 'when API is disabled' do
      before { allow(user_invite).to receive(:enabled?).and_return(false) }

      it 'raises an ApiDisabled error' do
        expect { user_invite.create }.to raise_error(Schools::DFESignInAPI::UserInvite::ApiDisabled)
      end
    end
  end
end
