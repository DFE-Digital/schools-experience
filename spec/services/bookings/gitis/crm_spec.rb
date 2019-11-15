require 'rails_helper'
require 'apimock/gitis_crm'

describe Bookings::Gitis::CRM, type: :model do
  include_context 'test entity'
  include_context 'bypass fake Gitis'

  let(:client_id) { 'clientid' }
  let(:client_secret) { 'clientsecret' }
  let(:tenant_id) { SecureRandom.uuid }
  let(:gitis_url) { 'https://gitis-crm.net' }
  let(:token) { 'my.secret.token' }

  let(:gitis) do
    described_class.new \
      Bookings::Gitis::Store::Dynamics.new \
        token, service_url: gitis_url
  end

  let(:gitis_stub) do
    Apimock::GitisCrm.new(client_id, client_secret, tenant_id, gitis_url)
  end

  describe '.initialize' do
    it "will succeed with store object" do
      expect(described_class.new(Bookings::Gitis::Store::Fake.new)).to \
        be_instance_of(Bookings::Gitis::CRM)
    end

    it "will raise an exception without a store" do
      expect { described_class.new }.to raise_exception(ArgumentError)
    end
  end

  describe '#find' do
    let(:contact) { build(:gitis_contact, :persisted) }
    before do
      expect(gitis.store).to \
        receive(:find).with(
          Bookings::Gitis::Contact, contact.id, includes: nil
        ).and_return(contact)
    end
    subject! { gitis.find contact.id }
    it { is_expected.to eq contact }
  end

  describe '#find_by_email' do
    let(:email) { 'me@something.com' }
    before { gitis_stub.stub_contact_request_by_email(email) }
    subject { gitis.find_by_email(email) }

    it "will return a contact record" do
      is_expected.to be_instance_of(Bookings::Gitis::Contact)
      is_expected.to have_attributes(email: email)
    end
  end

  describe '#find_contact_for_signin' do
    let(:email) { 'testy@mctest.com' }
    let(:firstuuid) { SecureRandom.uuid }
    let(:seconduuid) { SecureRandom.uuid }

    let(:signin_attrs) do
      {
        'emailaddress1' => email,
        'firstname' => 'testy',
        'lastname' => 'mctest',
        'birthdate' => '1980-01-01'
      }
    end

    subject do
      gitis.find_contact_for_signin(
        email: 'testy@mctest.com',
        firstname: 'testy',
        lastname: 'mctest',
        date_of_birth: Date.parse('1980-01-01')
      )
    end

    context 'with no match' do
      before { gitis_stub.stub_contact_signin_request(email, {}) }
      it { is_expected.to be_nil }
    end

    context 'with a single email match' do
      context 'and matching other fields' do
        before do
          gitis_stub.stub_contact_signin_request(email,
            firstuuid => signin_attrs)
        end

        it "will return contact with correct gitis uuid" do
          is_expected.to have_attributes id: firstuuid
        end
      end

      context 'and not matching other fields' do
        before do
          gitis_stub.stub_contact_signin_request(email,
            firstuuid => signin_attrs)
        end

        it "needs to be discussed"
      end
    end

    context 'with multiple matches' do
      before do
        gitis_stub.stub_contact_signin_request(email,
          firstuuid => signin_attrs.merge('emailaddress1' => 'foo@bar.com', 'emailaddress2' => email),
          seconduuid => signin_attrs.merge('firstname' => 'Joe', 'lastname' => 'Bloggs'))
      end

      it "will return the first contact record" do
        is_expected.to have_attributes(id: firstuuid)
      end
    end
  end

  describe '#write' do
    let(:contactid) { SecureRandom.uuid }
    let(:contact) { build(:gitis_contact) }
    before { expect(gitis.store).to receive(:write).and_return(contactid) }
    subject! { gitis.write contact }
    it { is_expected.to eq contactid }
  end

  describe '#fetch' do
    before { allow(gitis.store).to receive(:fetch).and_return([]) }
    before { gitis.fetch TestEntity, limit: 3 }
    it { expect(gitis.store).to have_received(:fetch) }
  end

  describe "#log_school_experience" do
    let(:school) { build(:bookings_school) }
    let(:contact) { build(:gitis_contact, :persisted) }
    let(:headerline) { Bookings::Gitis::EventLogger::NOTES_HEADER }
    let(:logline) { "01/10/2019 TEST                   01/11/2019 #{school.urn} #{school.name}" }

    before do
      allow(gitis).to receive(:find).with(contact.id).and_return(contact)
      allow(gitis.store).to receive(:update_entity).and_return(true)

      gitis.log_school_experience(contact.id, logline)
    end

    it "will create a new entry with a single row" do
      expect(gitis.store).to have_received(:update_entity).with(
        contact.entity_id,
        'dfe_notesforclassroomexperience' => "#{headerline}\r\n\r\n#{logline}\r\n"
      )
    end
  end
end
