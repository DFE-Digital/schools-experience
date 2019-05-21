require 'rails_helper'
require 'apimock/gitis_crm'

describe Bookings::Gitis::CRM, type: :model do
  let(:client_id) { 'clientid' }
  let(:client_secret) { 'clientsecret' }
  let(:tenant_id) { SecureRandom.uuid }
  let(:gitis_url) { 'https://gitis-crm.net' }
  let(:token) { 'my.secret.token' }

#  let(:api) { Bookings::Gitis::API.new('my.secret.token', service_url: gitis_url) }
  let(:gitis) { described_class.new(token, service_url: gitis_url) }
  let(:gitis_stub) do
    Apimock::GitisCrm.new(client_id, client_secret, tenant_id, gitis_url)
  end

  describe '.initialize' do
    it "will succeed with api object" do
      expect(described_class.new(token)).to \
        be_instance_of(Bookings::Gitis::CRM)
    end

    it "will raise an exception without an api object" do
      expect { described_class.new }.to raise_exception(ArgumentError)
    end
  end

  describe '.find' do
    let!(:uuids) do
      [
        "03ec3075-a9f9-400f-bc43-a7a5cdf68579",
        "e46fd2c9-ad04-4ebb-bc2a-26f3ad323c56",
        "2ec079dd-35a2-419a-9d01-48d63c09cdcc"
      ]
    end

    context 'with no account_ids' do
      it "will raise an exception" do
        expect {
          gitis.find
        }.to raise_exception(ArgumentError)
      end
    end

    context 'with single account_ids' do
      before { gitis_stub.stub_contact_request(uuids[1]) }
      subject { gitis.find(uuids[1]) }

      it "will return a single account" do
        is_expected.to be_instance_of Bookings::Gitis::Contact
        is_expected.to have_attributes(id: uuids[1])
      end
    end

    context 'with multiple account_ids' do
      before { gitis_stub.stub_multiple_contact_request(uuids) }
      subject { gitis.find(*uuids) }

      it "will return an account per id" do
        is_expected.to have_attributes(length: 3)
        is_expected.to all be_instance_of(Bookings::Gitis::Contact)
        subject.each_with_index do |contact, index|
          expect(contact.id).to eq(uuids[index])
        end
      end
    end

    context 'with array of account_ids' do
      before { gitis_stub.stub_multiple_contact_request(uuids) }
      subject { gitis.find(uuids) }

      it "will return an account per id" do
        is_expected.to have_attributes(length: 3)
        is_expected.to all be_instance_of(Bookings::Gitis::Contact)
        subject.each_with_index do |contact, index|
          expect(contact.id).to eq(uuids[index])
        end
      end
    end
  end

  describe '.find_by_email' do
    let(:email) { 'me@something.com' }
    before { gitis_stub.stub_contact_request_by_email(email) }
    subject { gitis.find_by_email(email) }

    it "will return a contact record" do
      is_expected.to be_instance_of(Bookings::Gitis::Contact)
      is_expected.to have_attributes(email: email)
    end
  end

  describe '.write' do
    # Note: this is just stubbed functionality for now
    context 'with a valid contact' do
      before { @contact = build(:gitis_contact) }

      it "will succeed" do
        expect(gitis.write(@contact)).to eq("75c5a32d-d603-4483-956f-236fee7c5784")
      end
    end

    context 'without a contact' do
      it "will raise an exception" do
        expect {
          gitis.write(OpenStruct.new)
        }.to raise_exception(ArgumentError)
      end
    end

    context 'with an invalid contact' do
      before do
        @contact = build(:gitis_contact, email: '')
      end

      it "will return false" do
        expect(gitis.write(@contact)).to be false
      end
    end
  end
end
