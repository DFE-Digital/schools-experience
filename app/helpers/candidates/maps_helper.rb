require 'addressable'

module Candidates::MapsHelper
  BING_BASE_URL = "https://dev.virtualearth.net/REST/v1".freeze
  STATIC_MAP_URL = "#{BING_BASE_URL}/Imagery/Map/Road/{center_point}/{zoom_level}{?params*}".freeze

  def static_map_url(latitude, longitude, mapsize:, zoom: 10)
    return unless ENV['BING_MAPS_KEY'].present?

    location = "#{latitude},#{longitude}"

    params = {
      mapSize: mapsize,
      key: ENV['BING_MAPS_KEY'],
      pushpin: location
    }

    tmpl = Addressable::Template.new(STATIC_MAP_URL)
    tmpl.expand(params: params, zoom_level: zoom, center_point: location).to_s
  end
end
