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

if ENV['BING_MAPS_KEY'].present?
  Geocoder.configure(
    lookup: :bing,
    api_key: ENV['BING_MAPS_KEY'],
    units: :miles
  )
else
  Geocoder.configure(units: :miles)
end

# hardcode geocoder to return a specific single result when we're in the servertest
# environment
if Rails.env.eql?('servertest')
  require Rails.root.join("lib", "servertest", "geocoder")
end
