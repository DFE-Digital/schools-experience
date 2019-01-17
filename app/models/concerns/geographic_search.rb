require 'active_support/concern'

module GeographicSearch
  extend ActiveSupport::Concern
  GEOFACTORY = RGeo::Geographic.spherical_factory(srid: 4326)

  included do
    scope :close_to, ->(coordinates, radius: 10, column: 'coordinates') do
      where("st_dwithin(%<column>s, '%<coordinates>s', %<radius>d)" % {
        column: column,
        coordinates: coordinates,
        radius: Conversions::Distance::Miles::ToMetres.convert(radius)
      })
    end
  end
end
