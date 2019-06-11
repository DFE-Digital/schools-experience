require 'rails_helper'

RSpec.describe Candidates::Session, type: :model do
  include ActiveJob::TestHelper

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

  describe '#login' do
    before { NotifyFakeClient.reset_deliveries! }
    before { queue_adapter.perform_enqueued_jobs = true }
    after { queue_adapter.perform_enqueued_jobs = nil }
    subject { described_class.new(gitis, login_attrs) }

    context 'with known candidate' do
      let(:existing_attrs) { attrs.merge('contactid' => candidate.gitis_uuid) }
      let(:existing_contact) { Bookings::Gitis::Contact.new(existing_attrs) }

      before do
        expect(gitis).to receive(:find_contact_for_signin).and_return(existing_contact)
        @signed_in = subject.signin
      end

      it "will return the logged in candidate" do
        expect(@signed_in).to eql(candidate)
      end

      it "will create a token" do
        expect(candidate.session_tokens.count).to eql(1)
      end

      it "will send email with token link" do
        expect(NotifyFakeClient.deliveries.length).to eql(1)

        delivery = NotifyFakeClient.deliveries.first
        expect(delivery[:email_address]).to eql(attrs['emailaddress1'])

        token = Candidates::SessionToken.reorder(:id).last.token
        expect(delivery[:personalisation][:confirmation_link]).to \
          match(%r{/signin/#{token}\z})
        expect(delivery[:personalisation][:confirmation_link]).to \
          match(Rails.application.routes.url_helpers.candidates_signin_confirmation_url(token))
      end
    end

    context 'with unknown candidate' do
      let(:new_attrs) { attrs.merge('contactid' => SecureRandom.uuid) }
      let(:new_contact) { Bookings::Gitis::Contact.new(new_attrs) }

      context 'who exists in Gitis' do
        before do
          expect(gitis).to receive(:find_contact_for_signin).and_return(new_contact)
          @signed_in = subject.signin
        end

        it "will return the logged in candidate" do
          expect(@signed_in).to be_kind_of(Bookings::Candidate)
          expect(@signed_in).not_to eql(candidate) # check created new candidate
        end

        it "will create a token" do
          expect(@signed_in.session_tokens.count).to eql(1)
        end

        it "will send email with token link" do
          expect(NotifyFakeClient.deliveries.length).to eql(1)

          delivery = NotifyFakeClient.deliveries.first
          expect(delivery[:email_address]).to eql(attrs['emailaddress1'])

          token = Candidates::SessionToken.reorder(:id).last.token
          expect(delivery[:personalisation][:confirmation_link]).to \
            match(Rails.application.routes.url_helpers.candidates_signin_url(token))
        end
      end

      context 'who does not exist in Gitis' do
        before do
          expect(gitis).to receive(:find_contact_for_signin).and_return(false)
          @signed_in = subject.signin
        end

        it "will return false" do
          expect(@signed_in).to be false
        end

        it "will not create a token" do
          expect(Candidates::SessionToken.count).to eql(0)
        end

        it "will not send an email with token link" do
          expect(NotifyFakeClient.deliveries).to eql([])
        end
      end
    end
  end
end
