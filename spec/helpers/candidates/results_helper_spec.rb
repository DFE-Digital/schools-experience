require 'rails_helper'

describe Candidates::ResultsHelper, type: :helper do
  let(:search) { Candidates::SchoolSearch.new(query: 'School') }

  subject { school_results_info(search) }

  describe '#school_results_info' do
    context 'When there are no results' do
      specify { expect(subject).to eql('No results found') }
    end

    context 'When there fewer than one page of results' do
      let!(:schools) { create_list(:bookings_school, 5) }
      specify { expect(subject).to eql('Displaying all 5 results') }
    end

    context 'When there are more than one page of results' do
      let!(:schools) { create_list(:bookings_school, 18) }
      specify { expect(subject).to eql("Showing 1&ndash;15 of 18 results") }
    end
  end
end
