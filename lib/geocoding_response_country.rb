# We can retrieve country from the Geocoding response. However, it tends to return
# 'United Kingdom', whereas we are interested in the actual country (England, Scotland,
# Northern Ireland, Wales). Therefore, we need to actively search the result for countries.
# The country mostly comes through on the key 'administrative_area_level_1', but this
# doesn't seem to be consistent.
class GeocodingResponseCountry
  ENGLAND = "England".freeze
  COUNTRIES_NOT_SERVICED = ["Northern Ireland", "Scotland", "Wales"].freeze

  attr_reader :name

  def initialize(geocoding_response)
    @geocoding_response = geocoding_response

    @name = find_country_name(@geocoding_response)
  end

  def not_serviced?
    name != ENGLAND
  end

private

  def find_country_name(response)
    address_components = response.address_components.map(&:values).flatten
    all_countries.find { |region| address_components.include?(region) }
  end

  def all_countries
    COUNTRIES_NOT_SERVICED + [ENGLAND]
  end
end
