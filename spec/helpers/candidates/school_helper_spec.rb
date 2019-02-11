require 'rails_helper'

RSpec.describe Candidates::SchoolHelper, type: :helper do
  context '.format_school_address' do
    before do
      @school = OpenStruct.new(
        address_1: nil,
        address_2: 'Picadilly Gate',
        address_3: '',
        town: 'Manchester',
        county: 'Manchester',
        postcode: 'MA1 1AM'
      )

      @formatted = format_school_address(@school)
    end

    it 'should be html_safe' do
      expect(@formatted.html_safe?).to be true
    end

    it 'should concatenate non blank fields' do
      expect(@formatted).to eq "Picadilly Gate, Manchester, Manchester, MA1 1AM"
    end
  end

  context '.format_school_subjects' do
    before do
      @school = OpenStruct.new(
        subjects: [
          OpenStruct.new(id: 1, name: 'First'),
          OpenStruct.new(id: 2, name: 'Second'),
          OpenStruct.new(id: 3, name: 'Third')
        ]
      )

      @formatted = format_school_subjects(@school)
    end

    it 'should be html_safe' do
      expect(@formatted.html_safe?).to be true
    end

    it 'should turn them into a sentence' do
      expect(@formatted).to eq "First, Second, and Third"
    end
  end

  context '.format_school_phases' do
    before do
      @school = OpenStruct.new(
        phases: [
          OpenStruct.new(id: 1, name: 'First'),
          OpenStruct.new(id: 2, name: 'Second'),
          OpenStruct.new(id: 3, name: 'Third')
        ]
      )

      @formatted = format_school_phases(@school)
    end

    it 'should be html_safe' do
      expect(@formatted.html_safe?).to be true
    end

    it 'should turn them into a sentence' do
      expect(@formatted).to eq "First, Second, Third"
    end
  end
end
