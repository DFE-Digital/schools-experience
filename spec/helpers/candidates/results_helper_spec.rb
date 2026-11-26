require 'rails_helper'

describe Candidates::ResultsHelper, type: :helper do
  subject { school_results_info(search) }

  let(:point_in_manchester) { Bookings::School::GEOFACTORY.point(-2.241, 53.481) }

  let(:geocoder_manchester_search_result) do
    [
      Geocoder::Result::Test.new("latitude" => 53.488, "longitude" => -2.242, name: 'Manchester, UK', address_components: [{ long_name: "England" }]),
      Geocoder::Result::Test.new("latitude" => 53.476, "longitude" => -2.229, name: 'Manchester, UK', address_components: [{ long_name: "England" }])
    ]
  end
  let(:search) { Candidates::SchoolSearch.new(location: 'Manchester') }

  before do
    allow(Geocoder).to receive(:search).and_return(geocoder_manchester_search_result)
  end

  describe '#school_results_info' do
    context 'when there are no results' do
      specify { expect(subject).to eql('No results found') }
    end

    context 'when there fewer than one page of results' do
      before { create_list(:bookings_school, 5, :onboarded, coordinates: point_in_manchester) }

      specify { expect(subject).to eql('Displaying all 5 results') }
    end

    context 'when there are more than one page of results' do
      before { create_list(:bookings_school, 18, :onboarded, coordinates: point_in_manchester) }

      specify { expect(subject).to eql("Showing 1–15 of 18 results") }
    end
  end
end
