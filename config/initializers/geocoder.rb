require Rails.root.join('lib', 'geocoder_autoexpire_cache')
require File.join('geocoder', 'lookups', 'google')

defaults = {
  units: :miles,
  cache: GeocoderAutoexpireCache.new(Rails.cache)
}

if Rails.application.config.x.google_geocoding_key.present?
  Geocoder.configure(
    defaults.merge(
      lookup: :google,
      use_https: true,
      api_key: Rails.application.config.x.google_geocoding_key
    )
  )
else
  Geocoder.configure(defaults)
end

module GoogleOverrideURLParams
  def query_url_params(query)
    super.merge(c: 'en-gb')
  end
end

Geocoder::Lookup::Google.prepend(GoogleOverrideURLParams)
