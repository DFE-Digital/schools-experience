require 'rails_helper'

describe Bookings::Gitis::Contact, type: :model do
  describe '.entity_path' do
    subject { described_class.entity_path }
    it { is_expected.to eq('contacts') }
  end

  describe '.primary_key' do
    subject { described_class.primary_key }
    it { is_expected.to eq('contactid') }
  end

  describe '.initialize' do
    context "with data" do
      before do
        @contact = Bookings::Gitis::Contact.new(
          'contactid' => "d778d663-a022-4c4b-9962-e469ee179f4a",
          'firstname' => 'Testing',
          'lastname' => '123',
          'telephone2' => '01234 567890',
          'emailaddress1' => 'first@thisaddress.com',
          'address1_line1' => 'First Address Line',
          'address1_line2' => 'Second Address Line',
          'address1_line3' => 'Third Address Line',
          'address1_city' => 'Manchester',
          'address1_stateorprovince' => 'Manchester',
          'address1_postalcode' => 'MA1 1AM'
        )
      end

      it "will assign id" do
        expect(@contact.id).to eq "d778d663-a022-4c4b-9962-e469ee179f4a"
      end

      it "will assign entity_id" do
        expect(@contact.entity_id).to \
          eq("contacts(d778d663-a022-4c4b-9962-e469ee179f4a)")
      end

      it "will assign name" do
        expect(@contact.full_name).to eq "Testing 123"
      end

      it "will assign address" do
        expect(@contact.building).to eq "First Address Line"
        expect(@contact.street).to eq "Second Address Line, Third Address Line"
        expect(@contact.town_or_city).to eq "Manchester"
        expect(@contact.county).to eq "Manchester"
      end

      it "will assign postcode" do
        expect(@contact.postcode).to eq "MA1 1AM"
      end

      it "will assign email" do
        expect(@contact.email).to eq "first@thisaddress.com"
      end
    end

    context "without data" do
      it "will return an empty Contact" do
        expect(Bookings::Gitis::Contact.new.id).to be_nil
      end
    end
  end

  describe '#created_by_us?' do
    context 'with our record' do
      subject do
        build :gitis_contact, \
          dfe_channelcreation: described_class::channel_creation
      end

      it { is_expected.to be_created_by_us }
    end

    context 'with existing gitis record' do
      subject do
        build :gitis_contact, \
          dfe_channelcreation: described_class::channel_creation.to_s + '1'
      end

      it { is_expected.not_to be_created_by_us }
    end
  end

  describe "#email" do
    context "with primary address set" do
      subject { described_class.new(emailaddress1: 'first@test.com') }
      it { expect(subject.email).to eql('first@test.com') }
    end

    context "with both addresses set" do
      subject do
        described_class.new(
          emailaddress1: 'first@test.com',
          emailaddress2: 'second@test.com'
        )
      end

      it { expect(subject.email).to eql('second@test.com') }
    end
  end

  describe "#signin_attributes_match?" do
    let(:contact) { build(:gitis_contact) }
    let(:date_of_birth) { Date.parse(contact.birthdate) }
    subject { contact.signin_attributes_match?(*signin_attrs) }

    context 'with matching name' do
      let(:signin_attrs) do
        [contact.firstname, contact.lastname, Date.parse('2000-01-01')]
      end

      it { is_expected.to be true }
    end

    context 'with all matching' do
      let(:signin_attrs) do
        [contact.firstname, contact.lastname, date_of_birth]
      end

      it { is_expected.to be true }
    end

    context 'with matching dob' do
      let(:signin_attrs) { ['', '', date_of_birth] }
      it { is_expected.to be false }
    end

    context 'with partial name match and matching dob' do
      let(:signin_attrs) { ['', contact.lastname, date_of_birth] }
      it { is_expected.to be true }
    end
  end

  describe 'writing' do
    describe "#attributes_for_create" do
      let(:contact) do
        described_class.new.tap do |c|
          c.contactid     = SecureRandom.uuid
          c.first_name    = "Test"
          c.last_name     = "User"
          c.email         = 'testing@testaddress.education.gov.uk'
          c.date_of_birth = Date.parse('1980-01-01')
          c.phone         = '01234 567890'
          c.building      = 'My Building'
          c.street        = 'Test Street'
          c.town_or_city  = 'Test Town'
          c.county        = 'Test County'
          c.postcode      = 'MA1 1AM'
        end
      end

      subject { contact.attributes_for_create }
      it { is_expected.not_to include('contactid') }
      it { is_expected.to include('firstname') }
      it { is_expected.to include('lastname') }
      it { is_expected.to include('emailaddress1') }
      it { is_expected.to include('emailaddress2') }
      it { is_expected.to include('telephone2') }
      it { is_expected.to include('dfe_channelcreation') }
      it { is_expected.to include('dfe_Country@odata.bind') }
    end

    describe "#attributes_for_update" do
      let(:attrs) do
        attributes_for :gitis_contact, :persisted, dfe_channelcreation: channel
      end

      let(:contact) { Bookings::Gitis::Contact.new attrs }
      subject { contact.attributes_for_update }

      context 'with records we created' do
        let(:channel) { described_class::channel_creation }

        context 'when unmodified' do
          it { is_expected.not_to include('contactid') }
          it { is_expected.not_to include('dfe_channelcreation') }
          it { is_expected.not_to include('firstname') }
          it { is_expected.not_to include('lastname') }
          it { is_expected.not_to include('birthdate') }
          it { is_expected.to include('telephone2') }
          it { is_expected.to include('emailaddress2') }
          it { is_expected.not_to include('dfe_Country@odata.bind') }
        end

        context 'when modified' do
          before do
            contact.firstname = 'Different'
            contact.lastname = 'Different'
            contact.email = 'new@fictional-address.com'
            contact.phone = '0712345679'
          end

          it { is_expected.not_to include('contactid') }
          it { is_expected.not_to include('dfe_channelcreation') }
          it { is_expected.not_to include('firstname') }
          it { is_expected.not_to include('lastname') }
          it { is_expected.not_to include('birthdate') }
          it { is_expected.to include('emailaddress1') }
          it { is_expected.to include('emailaddress2') }
          it { is_expected.to include('telephone1') }
          it { is_expected.to include('telephone2') }
          it { is_expected.to include('address1_telephone1') }
          it { is_expected.not_to include('dfe_Country@odata.bind') }
        end
      end

      context "with other gitis records" do
        let(:channel) { described_class::channel_creation.to_s + '1' }

        context 'when unmodified' do
          it { is_expected.not_to include('contactid') }
          it { is_expected.not_to include('dfe_channelcreation') }
          it { is_expected.not_to include('firstname') }
          it { is_expected.not_to include('lastname') }
          it { is_expected.not_to include('birthdate') }
          it { is_expected.not_to include('emailaddress1') }
          it { is_expected.to include('emailaddress2') }
          it { is_expected.not_to include('telephone1') }
          it { is_expected.not_to include('address1_telephone1') }
          it { is_expected.to include('telephone2') }
          it { is_expected.not_to include('dfe_Country@odata.bind') }
        end

        context 'when modified' do
          before do
            contact.firstname = 'Different'
            contact.lastname = 'Different'
            contact.email = 'new@fictional-address.com'
            contact.phone = '0712345679'
          end

          it { is_expected.not_to include('contactid') }
          it { is_expected.not_to include('dfe_channelcreation') }
          it { is_expected.not_to include('firstname') }
          it { is_expected.not_to include('lastname') }
          it { is_expected.not_to include('birthdate') }
          it { is_expected.not_to include('emailaddress1') }
          it { is_expected.to include('emailaddress2') }
          it { is_expected.not_to include('telephone1') }
          it { is_expected.not_to include('address1_telephone1') }
          it { is_expected.to include('telephone2') }
          it { is_expected.not_to include('dfe_Country@odata.bind') }
        end
      end
    end
  end

  describe '#has_dbs_check' do
    subject do
      described_class.new(
        dfe_hasdbscertificate: true,
        dfe_dateofissueofdbscertificate: '2019-01-01'
      )
    end

    context 'with matching value' do
      before { subject.has_dbs_check = true }
      it { is_expected.to have_attributes(dfe_hasdbscertificate: true) }
      it { is_expected.to have_attributes(dfe_dateofissueofdbscertificate: '2019-01-01') }
    end

    context 'with non matching value' do
      before { subject.has_dbs_check = false }
      it { is_expected.to have_attributes(dfe_hasdbscertificate: false) }
      it { is_expected.to have_attributes(dfe_dateofissueofdbscertificate: nil) }
    end
  end

  describe '#phone=' do
    subject { described_class.new attrs }
    before { allow(subject).to receive(:created_by_us?).and_return(ours) }
    before { subject.phone = '01234567890' }

    context 'on existing GiTiS record for telephone1' do
      let(:ours) { false }

      context 'with blank' do
        let(:attrs) do
          { 'telephone1' => '', 'telephone2' => '' }
        end

        it { is_expected.to have_attributes(telephone1: '01234567890') }
        it { is_expected.to have_attributes(telephone2: '01234567890') }
      end

      context 'with matching' do
        let(:attrs) do
          { 'telephone1' => '01234567890', 'telephone2' => '07123456789' }
        end

        it { is_expected.to have_attributes(telephone1: '01234567890') }
        it { is_expected.to have_attributes(telephone2: '01234567890') }
      end

      context 'for unmatching' do
        let(:attrs) do
          { 'telephone1' => '07123456789', 'telephone2' => '07123456789' }
        end

        it { is_expected.to have_attributes(telephone1: '07123456789') }
        it { is_expected.to have_attributes(telephone2: '01234567890') }
      end
    end

    context 'on existing GiTiS record for address1_telephone1' do
      let(:ours) { false }

      context 'with blank' do
        let(:attrs) do
          { 'address1_telephone1' => '', 'telephone2' => '' }
        end

        it { is_expected.to have_attributes(address1_telephone1: '01234567890') }
        it { is_expected.to have_attributes(telephone2: '01234567890') }
      end

      context 'with matching' do
        let(:attrs) do
          { 'address1_telephone1' => '01234567890', 'telephone2' => '07123456789' }
        end

        it { is_expected.to have_attributes(address1_telephone1: '01234567890') }
        it { is_expected.to have_attributes(telephone2: '01234567890') }
      end

      context 'for unmatching' do
        let(:attrs) do
          { 'address1_telephone1' => '07123456789', 'telephone2' => '07123456789' }
        end

        it { is_expected.to have_attributes(address1_telephone1: '07123456789') }
        it { is_expected.to have_attributes(telephone2: '01234567890') }
      end
    end

    context 'on record we created' do
      let(:ours) { true }

      context 'for unmatching telephone1' do
        let(:attrs) do
          {
            'telephone1' => '07123456789',
            'address1_telephone1' => '07123456789',
            'telephone2' => '07123456789'
          }
        end

        it { is_expected.to have_attributes(telephone1: '01234567890') }
        it { is_expected.to have_attributes(address1_telephone1: '01234567890') }
        it { is_expected.to have_attributes(telephone2: '01234567890') }
      end
    end
  end

  describe '#email=' do
    subject { described_class.new attrs }
    before { allow(subject).to receive(:created_by_us?).and_return(ours) }
    before { subject.email = 'foobar@education.gov.uk' }

    context 'on existing GiTiS record' do
      let(:ours) { false }

      context 'with blank emailaddress1' do
        let(:attrs) do
          { 'emailaddress1' => '', 'emailaddress2' => '' }
        end

        it { is_expected.to have_attributes(emailaddress1: 'foobar@education.gov.uk') }
        it { is_expected.to have_attributes(emailaddress2: 'foobar@education.gov.uk') }
      end

      context 'with matching emailaddress1' do
        let(:attrs) do
          { 'emailaddress1' => 'foobar@education.gov.uk', 'emailaddress2' => 'barfoo@education.gov.uk' }
        end

        it { is_expected.to have_attributes(emailaddress1: 'foobar@education.gov.uk') }
        it { is_expected.to have_attributes(emailaddress2: 'foobar@education.gov.uk') }
      end

      context 'for unmatching emailaddress1' do
        let(:attrs) do
          { 'emailaddress1' => 'barfoo@education.gov.uk', 'emailaddress2' => 'barfoo@education.gov.uk' }
        end

        it { is_expected.to have_attributes(emailaddress1: 'barfoo@education.gov.uk') }
        it { is_expected.to have_attributes(emailaddress2: 'foobar@education.gov.uk') }
      end
    end

    context 'on record we created' do
      let(:ours) { true }

      context 'for unmatching emailaddress1' do
        let(:attrs) do
          { 'emailaddress1' => 'barfoo@education.gov.uk', 'emailaddress2' => 'barfoo@education.gov.uk' }
        end

        it { is_expected.to have_attributes(emailaddress1: 'foobar@education.gov.uk') }
        it { is_expected.to have_attributes(emailaddress2: 'foobar@education.gov.uk') }
      end
    end
  end

  describe '#add_school_experience' do
    let(:school) { build(:bookings_school) }
    let(:contact) { build(:gitis_contact, :persisted) }
    let(:headerline) { Bookings::Gitis::EventLogger::NOTES_HEADER }

    let(:logline) do
      "01/10/2019 TEST                   01/11/2019 #{school.urn} #{school.name}"
    end

    context 'with no prior experience' do
      before { contact.add_school_experience logline }
      subject { contact }

      it "will create a classroomexperience entry" do
        is_expected.to have_attributes \
          dfe_notesforclassroomexperience: "#{headerline}\r\n\r\n#{logline}\r\n"
      end

      it "will write the changes to the crm" do
        expect(contact.attributes_for_create).to include \
          'dfe_notesforclassroomexperience' => "#{headerline}\r\n\r\n#{logline}\r\n"
      end
    end

    context 'with prior experience' do
      let(:secondline) do
        "01/10/2019 BOOKED                 01/11/2019 #{school.urn} #{school.name}"
      end

      before do
        contact.dfe_notesforclassroomexperience = "#{headerline}\r\n\r\n#{logline}\r\n"
        contact.clear_changes_information
        contact.add_school_experience secondline
      end

      subject { contact }

      it "will append to the classroomexperience entry" do
        is_expected.to have_attributes \
          dfe_notesforclassroomexperience:
            "#{headerline}\r\n\r\n#{logline}\r\n#{secondline}\r\n"
      end

      it "will write the changes to the crm" do
        expect(subject.attributes_for_update).to include \
          'dfe_notesforclassroomexperience' =>
            "#{headerline}\r\n\r\n#{logline}\r\n#{secondline}\r\n"
      end
    end
  end
end
