require 'rails_helper'
require 'geocoding_response_country'

RSpec.describe GeocodingResponseCountry do
  describe "#name" do
    shared_examples "a known country" do |country|
      subject do
        described_class.new(response).name
      end

      let(:response) { Geocoder::Result::Test.new(address_components: [{ long_name: country }]) }


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
      subject do
        described_class.new(canada_response).name
      end

      let(:canada_response) { Geocoder::Result::Test.new(address_components: [{ long_name: "Canada" }]) }


      it "returns nil" do
        expect(subject).to be_nil
      end
    end
  end

  describe "#not_serviced?" do
    shared_examples "a country that is not serviced" do |country|
      subject do
        described_class.new(response).not_serviced?
      end

      let(:response) { Geocoder::Result::Test.new(address_components: [{ long_name: country }]) }


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
      subject do
        described_class.new(response).not_serviced?
      end

      let(:response) { Geocoder::Result::Test.new(address_components: [{ long_name: "England" }]) }


      it "returns false" do
        expect(subject).to be false
      end
    end
  end
end
