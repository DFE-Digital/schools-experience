require 'rails_helper'

RSpec.describe Bookings::GeocodingRequest, type: :model do
  let(:region) { "England" }

  context "when the request contains an unformatted postcode" do
    let(:badly_formatted_request) { "Three rivers KT125EJ" }

    it "formats the postcode" do
      geocoding_request = described_class.new(badly_formatted_request, region)
      expect(geocoding_request.formatted_request).to include("Three rivers KT12 5EJ")
    end
  end

  context "when the request is an unformatted postcode" do
    let(:badly_formatted_request) { "KT125EJ" }

    it "formats the postcode" do
      geocoding_request = described_class.new(badly_formatted_request, region)
      expect(geocoding_request.formatted_request).to start_with("KT12 5EJ")
    end
  end

  it "appends the region to the request" do
    geocoding_request = described_class.new("School name", region)
    expect(geocoding_request.formatted_request).to eq("School name, England")
  end

  it "does not modify the original request" do
    request = "KT125EJ"
    described_class.new(request, region)
    expect(request).to eq("KT125EJ")
  end
end
