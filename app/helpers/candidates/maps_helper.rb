require 'addressable'

module Candidates::MapsHelper
  BING_BASE_URL = "https://dev.virtualearth.net/REST/v1".freeze
  EXTERNAL_MAP_URL = "https://bing.com/maps/default.aspx?mode=D&rtp=~pos.{latitude}_{longitude}_{name}".freeze
  STATIC_MAP_URL = "#{BING_BASE_URL}/Imagery/Map/Road/{center_point}/{zoom_level}{?params*}".freeze

  def include_maps_in_head
    content_for :head do
      javascript_include_tag \
        "https://www.bing.com/api/maps/mapcontrol?callback=mapsLoadedCallback",
        defer: true, async: true
    end
  end

  def static_map_url(latitude, longitude, mapsize:, zoom: 10)
    return if Rails.application.config.x.bing_maps_key.blank?

    location = "#{latitude},#{longitude}"

    params = {
      mapSize: mapsize,
      key: Rails.application.config.x.bing_maps_key,
      pushpin: location
    }

    tmpl = Addressable::Template.new(STATIC_MAP_URL)
    tmpl.expand(params: params, zoom_level: zoom, center_point: location).to_s
  end

  def ajax_map(latitude, longitude, mapsize:, title: nil, description: nil,
    zoom: 10, described_by: nil, include_js_in_head: true)
    return if Rails.application.config.x.bing_maps_key.blank?

    map_data = {
      controller: 'map',
      map_latitude: latitude,
      map_longitude: longitude,
      map_title: title,
      map_description: description,
      map_api_key: Rails.application.config.x.bing_maps_key.to_s
    }

    static_url = static_map_url(
      latitude,
      longitude,
      mapsize: mapsize,
      zoom: zoom
    )

    include_maps_in_head if include_js_in_head

    aria_attributes = {
      'aria-label': "Map showing #{title}"
    }

    if described_by.present?
      aria_attributes[:'aria-describedby'] = described_by
    end

    content_tag :div, class: "embedded-map", data: map_data, **aria_attributes do
      content_tag :div, class: 'embedded-map__inner-container',
        data: { target: 'map.container' } do
        image_tag static_url, class: "embedded-map__nojs-img", alt: "Map showing #{title}", **aria_attributes
      end
    end
  end

  def external_map_url(latitude:, longitude:, name:)
    tmpl = Addressable::Template.new(EXTERNAL_MAP_URL)
    tmpl.expand(latitude: latitude, longitude: longitude, name: name).to_s
  end
end
