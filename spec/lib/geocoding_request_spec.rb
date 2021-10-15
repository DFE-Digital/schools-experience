require 'rails_helper'
require 'geocoding_request'

RSpec.describe GeocodingRequest do
  let(:region) { "England" }
  let(:search_request) { "School name" }

  describe "#format_address" do
    subject do
      geocoding_request = described_class.new(search_request, region)
      geocoding_request.format_address
    end

    context "when the request contains an unformatted postcode" do
      let(:search_request) { "Three rivers KT125EJ" }

      it "formats the postcode" do
        expect(subject).to include("Three rivers KT12 5EJ")
      end
    end

    context "when the request is an unformatted postcode" do
      let(:search_request) { "KT125EJ" }

      it "formats the postcode" do
        expect(subject).to start_with("KT12 5EJ")
      end
    end

    context "when the request contains a lower case postcode" do
      let(:search_request) { "kt125ej" }

      it "formats the postcode" do
        expect(subject).to start_with("KT12 5EJ")
      end
    end

    it "appends the region to the request" do
      expect(subject).to eq("School name, England")
    end

    it "does not modify the original request" do
      request = "KT125EJ"
      described_class.new(request, region)
      expect(request).to eq("KT125EJ")
    end
  end
end
