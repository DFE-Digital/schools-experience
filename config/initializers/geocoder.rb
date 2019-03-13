#Geocoder.configure(
#
#  if ENV['BING_MAPS_KEY'].present?
#    lookup:
#    api_key: ENV[[]]
#  end
#
#  # street address geocoding service (default :nominatim)
#  # lookup: :yandex,
#
#  # IP address geocoding service (default :ipinfo_io)
#  # ip_lookup: :maxmind,
#
#  # to use an API key:
#  # api_key: "...",
#
#  # geocoding service request timeout, in seconds (default 3):
#  # timeout: 5,
#
#  units: :miles
#)

require Rails.root.join('lib', 'geocoder_autoexpire_cache')

defaults = {
  units: :miles,
  cache: GeocoderAutoexpireCache.new(Rails.cache)
}

if ENV['BING_MAPS_KEY'].present?
  Geocoder.configure(
    defaults.merge(
      lookup: :bing,
      api_key: ENV['BING_MAPS_KEY']
    )
  )
else
  Geocoder.configure(defaults)
end
