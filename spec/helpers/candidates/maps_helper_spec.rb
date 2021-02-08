require 'rails_helper'

RSpec.describe Candidates::MapsHelper, type: :helper do
  before do
    allow(Rails.application.config.x).to receive(:google_maps_key) { '12345' }
    @latitude = "53.4782"
    @longitude = "-2.2299"
    @zoom = 8
  end

  context '.static_map_url' do
    subject do
      static_map_url(@latitude, @longitude, mapsize: [300, 200], zoom: @zoom)
    end

    it('should return a correct Google Maps url') do
      url = "https://maps.googleapis.com/maps/api/staticmap"
      params = "center=#{@latitude}%2C#{@longitude}&key=12345&markers=#{@latitude}%2C#{@longitude}&scale=2&size=300x200&zoom=#{@zoom}"
      expect(subject).to eq("#{url}?#{params}")
    end
  end

  context '.ajax_map' do
    subject { ajax_map(@latitude, @longitude, mapsize: [300, 200], zoom: @zoom) }

    it "should include wrapping div" do
      expect(subject).to match('class="embedded-map"')
    end

    it "should include map container div" do
      expect(subject).to match('class="embedded-map__inner-container"')
    end

    it "should include nested non-js fallback img" do
      expect(subject).to match(/<img /)
      expect(subject).to match(";markers=#{@latitude}%2C#{@longitude}")
    end
  end

  context '.external_map_url' do
    subject { external_map_url(latitude: @latitude, longitude: @longitude, name: 'test', zoom: @zoom) }

    it "should add in latitude and longitude" do
      expect(subject).to \
        eq("https://www.google.com/maps/dir/?api=1&destination=#{@latitude},#{@longitude}")
    end
  end
end
