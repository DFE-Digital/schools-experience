require 'rails_helper'

describe Candidates::ResultsHelper, type: :helper do
  let(:point_in_manchester) { Bookings::School::GEOFACTORY.point(-2.241, 53.481) }

  let(:geocoder_manchester_search_result) {
    [
      Geocoder::Result::Test.new("latitude" => 53.488, "longitude" => -2.242, name: 'Manchester, UK'),
      Geocoder::Result::Test.new("latitude" => 53.476, "longitude" => -2.229, name: 'Manchester, UK')
    ]
  }
  let(:search) { Candidates::SchoolSearch.new(location: 'Manchester') }

  subject { school_results_info(search) }

  before do
    allow(Geocoder).to receive(:search).and_return(geocoder_manchester_search_result)
  end

  describe '#school_results_info' do
    context 'When there are no results' do
      specify { expect(subject).to eql('No results found') }
    end

    context 'When there fewer than one page of results' do
      let!(:schools) { create_list(:bookings_school, 5, :with_flexible_availability, coordinates: point_in_manchester) }
      specify { expect(subject).to eql('Displaying all 5 results') }
    end

    context 'When there are more than one page of results' do
      let!(:schools) { create_list(:bookings_school, 18, :with_flexible_availability, coordinates: point_in_manchester) }
      specify { expect(subject).to eql("Showing 1&ndash;15 of 18 results") }
    end
  end
end
