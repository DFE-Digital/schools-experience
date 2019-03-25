require 'rails_helper'

RSpec.describe Candidates::MapsHelper, type: :helper do
  before do
    @orig_maps_key = ENV['BING_MAPS_KEY']
    ENV['BING_MAPS_KEY'] = '12345'
    @latitude = "53.4782"
    @longitude = "-2.2299"
  end

  after { ENV['BING_MAPS_KEY'] = @orig_maps_key }

  context '.static_map_url' do
    subject do
      static_map_url(@latitude, @longitude, mapsize: '300x200', zoom: 8)
    end

    it('should return a correct Bing Maps url') do
      url = "https://dev.virtualearth.net/REST/v1/Imagery/Map/Road/#{@latitude}%2C#{@longitude}/8"
      params = "mapSize=300x200&key=12345&pushpin=#{@latitude}%2C#{@longitude}"
      expect(subject).to eq("#{url}?#{params}")
    end
  end

  context '.ajax_map' do
    subject { ajax_map(@latitude, @longitude, mapsize: '300x200', zoom: 8) }

    it "should include wrapping div" do
      expect(subject).to match('class="embedded-map"')
    end

    it "should include map container div" do
      expect(subject).to match('class="embedded-map__inner-container"')
    end

    it "should include nested non-js fallback img" do
      expect(subject).to match(/<img /)
      expect(subject).to match("/#{@latitude}%2C#{@longitude}/")
    end
  end

  context '.external_map_url' do
    subject { external_map_url(latitude: @latitude, longitude: @longitude, name: 'test') }

    it "should add in latitude and longitude" do
      expect(subject).to \
        eq("https://bing.com/maps/default.aspx?mode=D&rtp=~pos.#{@latitude}_#{@longitude}_test")
    end
  end
end
