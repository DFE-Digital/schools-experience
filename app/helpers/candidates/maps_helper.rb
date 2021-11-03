require 'addressable'

module Candidates::MapsHelper
  GOOGLE_BASE_URL = "https://maps.googleapis.com".freeze
  EXTERNAL_MAP_URL = "https://www.google.com/maps/dir/?api=1&destination={latitude},{longitude}".freeze
  STATIC_MAP_URL = "#{GOOGLE_BASE_URL}/maps/api/staticmap{?params*}".freeze

  def static_map_url(latitude, longitude, mapsize:, zoom: 17, scale: 2)
    return if google_maps_api_key.blank?

    location = "#{latitude},#{longitude}"

    params = {
      center: location,
      key: google_maps_api_key,
      markers: location,
      scale: scale,
      size: mapsize.join('x'),
      zoom: zoom
    }

    tmpl = Addressable::Template.new(STATIC_MAP_URL)
    tmpl.expand(params: params).to_s
  end

  def ajax_map(latitude, longitude, mapsize:, title: nil, description: nil,
               zoom: 17, described_by: nil)
    return if google_maps_api_key.blank?

    map_data = {
      controller: 'map',
      map_api_key_value: google_maps_api_key,
      map_latitude_value: latitude,
      map_longitude_value: longitude,
      map_title_value: title,
      map_description_value: description
    }

    static_url = static_map_url(
      latitude,
      longitude,
      mapsize: mapsize,
      zoom: zoom
    )

    aria_attributes = {
      'aria-label': "Map showing #{title}"
    }

    if described_by.present?
      aria_attributes[:'aria-describedby'] = described_by
    end

    tag.div class: "embedded-map", data: map_data, **aria_attributes do
      tag.div class: 'embedded-map__inner-container',
              data: { map_target: 'container' } do
        image_tag static_url, class: "embedded-map__nojs-img", alt: "Map showing #{title}", **aria_attributes
      end
    end
  end

  def external_map_url(latitude:, longitude:, name:, zoom: 17)
    tmpl = Addressable::Template.new(EXTERNAL_MAP_URL)
    tmpl.expand(latitude: latitude, longitude: longitude, zoom: zoom, name: name).to_s
  end

private

  def google_maps_api_key
    Rails.application.config.x.google_maps_key
  end
end
