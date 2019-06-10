require 'rails_helper'

RSpec.describe Candidates::Session, type: :model do
  let(:gitis) { Bookings::Gitis::CRM.new('a-token') }
  let(:candidate) { create(:candidate) }
  let(:attrs) do
    {
      'firstname' => 'Test',
      'lastname' => 'User',
      'date_of_birth' => '1980-10-01',
      'email' => 'existing@candidate.com'
    }
  end
  let(:login_attrs) { attrs.symbolize_keys }

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

  describe '#login' do
    before { NotifyFakeClient.reset_deliveries! }
    subject { described_class.new(gitis) }

    context 'with known candidate' do
      let(:existing_attrs) { attrs.merge('contactid' => candidate.gitis_uuid) }
      let(:existing_contact) { Bookings::Gitis::Contact.new(existing_attrs) }

      before do
        expect(gitis).to receive(:find_contact_for_signin).and_return(existing_contact)
        @signed_in = subject.login(**login_attrs)
      end

      it "will return the logged in candidate" do
        expect(@signed_in).to eql(candidate)
      end

      it "will create a token" do
        expect(candidate.session_tokens.count).to eql(1)
      end

      it "will send email with token link"
    end

    context 'with unknown candidate' do
      let(:new_attrs) { attrs.merge('contactid' => SecureRandom.uuid) }
      let(:new_contact) { Bookings::Gitis::Contact.new(new_attrs) }

      context 'who exists in Gitis' do
        before do
          expect(gitis).to receive(:find_contact_for_signin).and_return(new_contact)
          @signed_in = subject.login(**login_attrs)
        end

        it "will return the logged in candidate" do
          expect(@signed_in).to be_kind_of(Bookings::Candidate)
          expect(@signed_in).not_to eql(candidate) # check created new candidate
        end

        it "will create a token" do
          expect(@signed_in.session_tokens.count).to eql(1)
        end

        it "will send email with token link"
      end

      context 'who does not exist in Gitis' do
        before do
          expect(gitis).to receive(:find_contact_for_signin).and_return(false)
          @signed_in = subject.login(**login_attrs)
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
