require 'rails_helper'

RSpec.describe Candidates::MapsHelper, type: :helper do
  context '.static_map_url' do
    before do
      @orig_maps_key = ENV['BING_MAPS_KEY']
      ENV['BING_MAPS_KEY'] = '12345'
      @latitude = "53.4782"
      @longitude = "-2.2299"
    end

    after { ENV['BING_MAPS_KEY'] = @orig_maps_key }

    subject do
      static_map_url(@latitude, @longitude, mapsize: '300x200', zoom: 8)
    end

    it('should return a correct Bing Maps url') do
      url = "https://dev.virtualearth.net/REST/v1/Imagery/Map/Road/#{@latitude}%2C#{@longitude}/8"
      params = "mapSize=300x200&key=12345&pushpin=#{@latitude}%2C#{@longitude}"
      expect(subject).to eq("#{url}?#{params}")
    end
  end
end
