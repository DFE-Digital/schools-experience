require 'rails_helper'

describe Schools::PlacementRequests::ReviewAndSendEmail, type: :model do
  attributes = %i(candidate_instructions).freeze
  describe 'Attributes' do
    attributes.each do |attribute_name|
      let(:attribute_name) { attribute_name }
      specify "should have attribute #{attribute_name}" do
        expect(subject).to respond_to(attribute_name)
      end
    end
  end

  describe 'Validation' do
    attributes.each do |attribute_name|
      let(:attribute_name) { attribute_name }
      specify "should have attribute #{attribute_name}" do
        expect(subject).to validate_presence_of(attribute_name)
      end
    end
  end
end
