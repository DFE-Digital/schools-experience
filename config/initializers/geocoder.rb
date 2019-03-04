Geocoder.configure(
  # street address geocoding service (default :nominatim)
  # lookup: :yandex,

  # IP address geocoding service (default :ipinfo_io)
  # ip_lookup: :maxmind,

  # to use an API key:
  # api_key: "...",

  # geocoding service request timeout, in seconds (default 3):
  # timeout: 5,

  units: :miles
)

# hardcode geocoder to return a specific single result when we're in the servertest
# environment
if Rails.env.eql?('servertest')
  require Rails.root.join("lib", "servertest", "geocoder")
end
