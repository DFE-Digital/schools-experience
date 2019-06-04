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
        expect(subject).to validate_presence_of(attribute_name)
      end
    end
  end
end
