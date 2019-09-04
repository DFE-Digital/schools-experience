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

  describe '#find' do
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
        'date_of_birth' => '1980-01-01'
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
    let(:contact_attributes) { attributes_for(:gitis_contact) }

    context 'with a valid new contact' do
      let(:contact) { build(:gitis_contact, contact_attributes) }

      before do
        sorted_attrs = contact.attributes_for_create.sort.to_h
        gitis_stub.stub_create_contact_request(sorted_attrs, contactid)
      end

      subject { gitis.write(contact) }

      it "will return the id of the inserted record" do
        is_expected.to eq(contactid)
      end
    end

    context 'with a valid existing contact' do
      before do
        @contact = build(:gitis_contact, contact_attributes.merge(id: contactid))
        @contact.reset_dirty_attributes
        @contact.address1_line1 = 'Changed'
        @contact.address1_line2 = 'Address'
        gitis_stub.stub_update_contact_request(
          { 'address1_line1' => 'Changed', 'address1_line2' => 'Address' },
          contactid
        )
      end

      it "will succeed" do
        expect(gitis.write(@contact)).to eq(contactid)
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
      let(:contact) { build(:gitis_contact, emailaddress1: '') }
      before { gitis_stub.stub_create_contact_request(contact.attributes) }

      it "will return false" do
        expect(gitis.write(contact)).to be false
      end
    end
  end

  describe '#fetch' do
    let(:selectattrs) { TestEntity.attributes_to_select }
    let(:t1) { { 'testentityid' => SecureRandom.uuid, 'firstname' => 'A', 'lastname' => '1' } }
    let(:t2) { { 'testentityid' => SecureRandom.uuid, 'firstname' => 'B', 'lastname' => '2' } }
    let(:t3) { { 'testentityid' => SecureRandom.uuid, 'firstname' => 'C', 'lastname' => '3' } }
    let(:response) { [TestEntity.new(t1), TestEntity.new(t2), TestEntity.new(t3)] }

    context 'without entity' do
      it "will raise an error" do
        expect { subject.fetch }.to raise_exception(ArgumentError)
      end
    end

    context 'with entity and no filter' do
      before do
        expect(gitis.send(:api)).to receive(:get).
          with('testentities', '$top' => 10, '$select' => selectattrs).
          and_return('value' => [t1, t2, t3])
      end

      subject { gitis.fetch(TestEntity) }
      it { is_expected.to eq(response) }
    end

    context 'with entity and string filter' do
      before do
        expect(gitis.send(:api)).to receive(:get).
          with(
            'testentities',
            '$top' => 10,
            '$select' => selectattrs,
            '$filter' => "firstname eq 'test'"
          ).
          and_return('value' => [t1, t2, t3])
      end

      subject { gitis.fetch(TestEntity, filter: "firstname eq 'test'") }
      it { is_expected.to eq(response) }
    end

    context 'with entity and limit' do
      before do
        expect(gitis.send(:api)).to receive(:get).
          with('testentities', '$top' => 5, '$select' => selectattrs).
          and_return('value' => [t1, t2, t3])
      end

      subject { gitis.fetch(TestEntity, limit: 5) }
      it { is_expected.to eq(response) }
    end

    context 'with entity and order' do
      before do
        expect(gitis.send(:api)).to receive(:get).
          with(
            'testentities',
            '$top' => 5,
            '$select' => selectattrs,
            '$orderby' => 'createdon desc'
          ).and_return('value' => [t1, t2, t3])
      end

      subject { gitis.fetch(TestEntity, limit: 5, order: 'createdon desc') }
      it { is_expected.to eq(response) }
    end
  end

  describe "#log_school_experience" do
    let(:school) { build(:bookings_school) }
    let(:contact) { build(:gitis_contact, :persisted) }
    let(:headerline) { Bookings::Gitis::EventLogger::NOTES_HEADER }
    let(:logline) { "01/10/2019 TEST                   01/11/2019 #{school.urn} #{school.name}" }

    before do
      allow(gitis).to receive(:find).with(contact.id, refresh: true).and_return(contact)
      allow(gitis).to receive(:update_entity).and_return(true)

      gitis.log_school_experience(contact.id, logline)
    end

    it "will create a new entry with a single row" do
      expect(gitis).to have_received(:update_entity).with(
        contact.entity_id,
        'dfe_notesforclassroomexperience' => "#{headerline}\n\n#{logline}\n"
      )
    end
  end

  context 'with caching enabled' do
    let(:uuid) { "03ec3075-a9f9-400f-bc43-a7a5cdf68579" }

    before do
      allow(Rails.application.config.x.gitis).to \
        receive(:caching).and_return(true)
    end

    context '.find' do
      let(:contact) do
        build(:gitis_contact, :persisted, contactid: uuid, firstname: 'cached')
      end

      let(:cache_key) { "bookings/gitis/contacts/#{uuid}/v1" }

      before do
        Rails.cache.clear
        Rails.cache.write(cache_key, contact, expires_in: 5.minutes)
      end

      context "with single entity" do
        before { allow(Rails.cache).to receive(:write).and_call_original }

        context 'without refresh: true' do
          subject { gitis.find(uuid) }

          context 'and already in cache' do
            it { is_expected.to have_attributes(firstname: 'cached') }
            it { expect(Rails.cache).not_to have_received(:write) }
          end

          context 'after write of entity' do
            before do
              gitis_stub.stub_update_contact_request({ address1_line1: 'modified' }, uuid)
              gitis_stub.stub_contact_request(uuid, address1_line1: 'modified')
              contact.address1_line1 = 'modified'
              gitis.write contact
            end

            it "Will requery and update cache" do
              is_expected.to have_attributes(address1_line1: 'modified')

              expect(Rails.cache).to have_received(:write).with \
                "bookings/gitis/contacts/#{uuid}/v1",
                contact,
                hash_including(expires_in: 1.hour)
            end
          end
        end

        context 'with refresh: true' do
          before do
            gitis_stub.stub_contact_request(uuid, firstname: 'nocache')
          end

          subject { gitis.find(uuid, refresh: true) }

          it "will requery and update cache" do
            is_expected.to have_attributes(firstname: 'nocache')

            expect(Rails.cache).to have_received(:write).with \
              "bookings/gitis/contacts/#{uuid}/v1",
              subject,
              hash_including(expires_in: 1.hour)
          end
        end
      end

      context 'with multiple entities' do
        let(:second_uuid) { SecureRandom.uuid }
        let(:second_key) { "bookings/gitis/contacts/#{second_uuid}/v1" }

        let(:second) do
          build(:gitis_contact, :persisted,
            contactid: second_uuid,
            firstname: 'cached',
            lastname: 'second')
        end

        before do
          Rails.cache.write(second_key, second, expires_in: 5.minutes)
          allow(Rails.cache).to receive(:write).and_call_original
        end

        context 'without refresh: true' do
          context 'and already in cache' do
            subject { gitis.find([uuid, second_uuid]) }
            it { expect(subject[0]).to have_attributes(firstname: 'cached') }
            it { expect(subject[1]).to have_attributes(firstname: 'cached') }
            it { expect(subject[1]).to have_attributes(lastname: 'second') }
            it { expect(Rails.cache).not_to have_received(:write) }
          end

          context 'and some uuids in cache' do
            let(:third_uuid) { SecureRandom.uuid }
            let(:third_key) { "bookings/gitis/contacts/#{third_uuid}/v1" }

            let(:third) do
              build(:gitis_contact, :persisted, contactid: third_uuid, firstname: 'third')
            end

            before { gitis_stub.stub_multiple_contact_request([third_uuid], firstname: 'third') }

            subject { gitis.find([uuid, second_uuid, third_uuid]) }

            it "will uncached contact missing to cache" do
              expect(subject[0]).to have_attributes(firstname: 'cached')
              expect(subject[1]).to have_attributes(firstname: 'cached')
              expect(subject[2]).to have_attributes(firstname: 'third')

              expect(Rails.cache).to have_received(:write).with \
                third_key, third, hash_including(expires_in: 1.hour)
            end
          end
        end

        context 'with refresh: true' do
          before do
            gitis_stub.stub_multiple_contact_request([uuid, second_uuid],
              firstname: 'fresh')
          end

          subject { gitis.find([uuid, second_uuid], refresh: true) }

          it "will requery and update cache" do
            expect(subject[0]).to have_attributes(firstname: 'fresh')
            expect(subject[1]).to have_attributes(firstname: 'fresh')

            expect(Rails.cache).to have_received(:write).with \
              "bookings/gitis/contacts/#{uuid}/v1",
              contact,
              hash_including(expires_in: 1.hour)

            expect(Rails.cache).to have_received(:write).with \
              "bookings/gitis/contacts/#{second_uuid}/v1",
              second,
              hash_including(expires_in: 1.hour)
          end
        end
      end
    end
  end
end
