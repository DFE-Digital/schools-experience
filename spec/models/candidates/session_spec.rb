require 'rails_helper'

RSpec.describe Candidates::Session, type: :model do
  let(:candidate) { create(:candidate) }
  let(:attrs) do
    {
      'firstname' => 'Test',
      'lastname' => 'User',
      'emailaddress1' => 'existing@candidate.com'
    }
  end

  let(:login_attrs) do
    {
      firstname: 'Test',
      lastname: 'User',
      email: 'existing@candidate.com'
    }
  end

  describe 'validates' do
    subject { described_class.new }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:firstname) }
    it { is_expected.to validate_presence_of(:lastname) }
    it { is_expected.to allow_value('test@testymctest.com').for(:email) }
    it { is_expected.not_to allow_value('testymctest.com').for(:email) }
    it { is_expected.not_to allow_value('test@testymctest').for(:email) }
  end

  describe '.signin!' do
    let!(:first) { create(:candidate_session_token) }
    let!(:token) { create(:candidate_session_token, candidate: first.candidate) }

    context 'with valid token' do
      before { @candidate = described_class.signin!(token.token) }

      it { expect(@candidate).to eql(token.candidate) }

      it "should clear out other tokens" do
        expect(token.candidate.session_tokens.valid.count).to eql(0)
      end
    end

    context 'with unknown token' do
      before { @candidate = described_class.signin!('UNKNOWNTOKEN') }

      it { expect(@candidate).to be_nil }

      it "should not remove tokens" do
        expect(Candidates::SessionToken.valid.count).to eql(2)
      end
    end
  end
end
