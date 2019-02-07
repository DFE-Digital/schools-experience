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
end
