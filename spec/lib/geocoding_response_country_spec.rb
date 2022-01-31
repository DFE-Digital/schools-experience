require 'rails_helper'
require 'geocoding_response_country'

RSpec.describe GeocodingResponseCountry do
  describe "#name" do
    shared_examples "a known country" do |country|
      let(:response) { Geocoder::Result::Test.new(address_components: [long_name: country]) }

      subject do
        described_class.new(response).name
      end

      it "returns '#{country}'" do
        expect(subject).to eq country
      end
    end

    context "when Scotland" do
      it_behaves_like "a known country", "Scotland"
    end

    context "when Wales" do
      it_behaves_like "a known country", "Wales"
    end

    context "when Northern Ireland" do
      it_behaves_like "a known country", "Northern Ireland"
    end

    context "when England" do
      it_behaves_like "a known country", "England"
    end

    context "when unknown country" do
      let(:canada_response) { Geocoder::Result::Test.new(address_components: [long_name: "Canada"]) }

      subject do
        described_class.new(canada_response).name
      end

      it "returns nil" do
        expect(subject).to be nil
      end
    end
  end

  describe "#not_serviced?" do
    shared_examples "a country that is not serviced" do |country|
      let(:response) { Geocoder::Result::Test.new(address_components: [long_name: country]) }

      subject do
        described_class.new(response).not_serviced?
      end

      it "returns true" do
        expect(subject).to be true
      end
    end

    context "when Scotland" do
      it_behaves_like "a country that is not serviced", "Scotland"
    end

    context "when Wales" do
      it_behaves_like "a country that is not serviced", "Wales"
    end

    context "when Northern Ireland" do
      it_behaves_like "a country that is not serviced", "Northern Ireland"
    end

    context "when unknown country" do
      it_behaves_like "a country that is not serviced", "Canada"
    end

    context "when England" do
      let(:response) { Geocoder::Result::Test.new(address_components: [long_name: "England"]) }

      subject do
        described_class.new(response).not_serviced?
      end

      it "returns false" do
        expect(subject).to be false
      end
    end
  end
end
