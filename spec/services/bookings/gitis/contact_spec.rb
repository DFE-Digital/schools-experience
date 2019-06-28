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
          'mobilephone' => '07123 456789',
          'telephone1' => '01234 567890',
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
      it { is_expected.to include('statecode') }
      it { is_expected.to include('dfe_channelcreation') }
    end

    describe "#attributes_for_update" do
      let(:contact) { build(:gitis_contact, :persisted, dfe_channelcreation: nil) }
      subject { contact.attributes_for_update }

      context 'when unmodified' do
        it { is_expected.not_to include('contactid') }
        it { is_expected.not_to include('statecode') }
        it { is_expected.not_to include('dfe_channelcreation') }
      end

      context 'when modified' do
        before do
          contact.firstname = 'Different'
          contact.lastname = 'Different'
          contact.email = 'new@fictional-address.com'
          contact.phone = '0712345679'
        end

        it { is_expected.not_to include('contactid') }
        it { is_expected.not_to include('statecode') }
        it { is_expected.not_to include('dfe_channelcreation') }
        it { is_expected.to include('firstname') }
        it { is_expected.to include('lastname') }
        it { is_expected.to include('emailaddress2') }
        it { is_expected.to include('telephone2') }
      end
    end
  end
end
