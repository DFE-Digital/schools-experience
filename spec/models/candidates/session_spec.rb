require 'rails_helper'

RSpec.describe Candidates::Session, type: :model do
  let(:gitis) { Bookings::Gitis::CRM.new('a-token') }
  let(:candidate) { create(:candidate) }
  let(:attrs) do
    {
      'firstname' => 'Test',
      'lastname' => 'User',
      'date_of_birth' => '1980-10-01',
      'emailaddress1' => 'existing@candidate.com'
    }
  end

  let(:login_attrs) do
    {
      firstname: 'Test',
      lastname: 'User',
      date_of_birth: '1980-10-01',
      email: 'existing@candidate.com'
    }
  end

  describe '.new' do
    context 'with crm instance' do
      subject { described_class.new(gitis) }
      it "will return instance" do
        is_expected.to be_kind_of Candidates::Session
      end
    end

    context 'without crm instance' do
      it "will raise error" do
        expect { described_class.new }.to raise_exception(ArgumentError)
      end
    end
  end

  describe 'validates' do
    subject { described_class.new(gitis) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:firstname) }
    it { is_expected.to validate_presence_of(:lastname) }
    it { is_expected.to validate_presence_of(:date_of_birth) }
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

  describe '#create_signin_token' do
    subject { described_class.new(gitis, login_attrs) }

    context 'with known candidate' do
      let(:existing_attrs) { attrs.merge('contactid' => candidate.gitis_uuid) }
      let(:existing_contact) { Bookings::Gitis::Contact.new(existing_attrs) }

      before do
        expect(gitis).to receive(:find_contact_for_signin).and_return(existing_contact)
        @token = subject.create_signin_token
      end

      it "will return the logged in candidate" do
        expect(subject.candidate).to eql(candidate)
      end

      it "will create a token" do
        expect(candidate.session_tokens.count).to eql(1)
      end
    end

    context 'with unknown candidate' do
      let(:new_attrs) { attrs.merge('contactid' => SecureRandom.uuid) }
      let(:new_contact) { Bookings::Gitis::Contact.new(new_attrs) }

      context 'who exists in Gitis' do
        before do
          expect(gitis).to receive(:find_contact_for_signin).and_return(new_contact)
          @token = subject.create_signin_token
        end

        it "will return the logged in candidate" do
          expect(subject.candidate).to be_kind_of(Bookings::Candidate)
          expect(subject.candidate).not_to eql(candidate) # check created new candidate
        end

        it "will create a token" do
          expect(subject.candidate.session_tokens.count).to eql(1)
        end
      end

      context 'who does not exist in Gitis' do
        before do
          expect(gitis).to receive(:find_contact_for_signin).and_return(false)
          @token = subject.create_signin_token
        end

        it "will return false" do
          expect(@token).to be false
        end

        it "will not create candidate" do
          expect(subject.candidate).to be_nil
          expect(Bookings::Candidate.count).to eql(0)
        end

        it "will not create a token" do
          expect(Candidates::SessionToken.count).to eql(0)
        end
      end
    end
  end
end
