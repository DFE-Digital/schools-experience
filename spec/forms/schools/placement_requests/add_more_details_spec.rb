require 'rails_helper'

describe Schools::PlacementRequests::AddMoreDetails, type: :model do
  describe 'Attributes' do
    %i(contact_name contact_number contact_email location).each do |attribute_name|
      let(:attribute_name) { attribute_name }
      specify "should have attribute #{attribute_name}" do
        expect(subject).to respond_to(attribute_name)
      end
    end
  end

  describe 'Validation' do
    %i(contact_name contact_number contact_email location).each do |attribute_name|
      let(:attribute_name) { attribute_name }
      specify "should have attribute #{attribute_name}" do
        expect(subject).to validate_presence_of(attribute_name).with_message(/\AEnter a/)
      end
    end

    it { is_expected.to validate_email_format_of(:contact_email).with_message('Enter a valid email address') }
  end

  describe 'Methods' do
    describe '.for_school' do
      context 'when there is a previous accepted booking' do
        let(:contact_name) { 'David Test' }
        let(:contact_email) { 'd.test@some-school.org' }
        let(:contact_number) { '01234 456 678' }
        let(:location) { 'Reception in the East building' }

        let!(:booking) do
          create(
            :bookings_booking,
            :accepted,
            contact_name: contact_name,
            contact_email: contact_email,
            contact_number: contact_number,
            location: location
          )
        end

        subject { described_class.for_school(booking.bookings_school) }

        specify 'should initialize a Schools::PlacementRequests::AddMoreDetails' do
          expect(subject).to be_a(Schools::PlacementRequests::AddMoreDetails)
        end

        specify 'should have the correct attributes assigned' do
          expect(subject.contact_name).to eql(contact_name)
          expect(subject.contact_email).to eql(contact_email)
          expect(subject.contact_number).to eql(contact_number)
          expect(subject.location).to eql(location)
        end
      end

      context 'when there are no previous accepted bookings' do
        let(:school) { create(:bookings_school) }
        subject { described_class.for_school(school) }

        specify 'should initialize a Schools::PlacementRequests::AddMoreDetails' do
          expect(subject).to be_a(Schools::PlacementRequests::AddMoreDetails)
        end

        specify 'should have no attributes assigned' do
          expect(subject.contact_name).to be_nil
          expect(subject.contact_email).to be_nil
          expect(subject.contact_number).to be_nil
          expect(subject.location).to be_nil
        end
      end
    end
  end
end
