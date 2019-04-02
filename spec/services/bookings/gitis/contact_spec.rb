require 'rails_helper'

describe Bookings::Gitis::Contact, type: :model do
  describe '.initialize' do
    context "with data" do
      before do
        @contact = Bookings::Gitis::Contact.new(
          'AccountId' => '1',
          'AccountIdName' => 'Testing 123',
          'MobilePhone' => '07123 456789',
          'Telephone1' => '01234 567890',
          'EmailAddress1' => 'first@thisaddress.com',
          'EmailAddress2' => 'second@thisaddress.com',
          'EmailAddress3' => 'third@thisaddress.com',
          'Address1_Line1' => 'First Address Line',
          'Address1_Line2' => 'Second Address Line',
          'Address1_Line3' => 'Third Address Line',
          'Address1_City' => 'Manchester',
          'Address1_StateOrProvince' => 'Manchester',
          'Address1_PostalCode' => 'MA1 1AM'
        )
      end

      it "will assign id" do
        expect(@contact.id).to eq "1"
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
      it "will raise an ArgumentError" do
        expect {
          Bookings::Gitis::Contact.new
        }.to raise_exception ArgumentError
      end
    end
  end
end
