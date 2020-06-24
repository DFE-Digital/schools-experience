require 'active_support/concern'

module GeographicSearch
  extend ActiveSupport::Concern
  GEOFACTORY = RGeo::Geographic.spherical_factory(srid: 4326)
  DEFAULT_RADIUS = 10

  included do
    # Returns records that fall within a radius of a point using PostGIS
    # functionality via RGeo to perform the query
    #
    # @param [RGeo::Geographic::SphericalPointImpl] point The coordinates
    #   of the search coordinates. If +nil+, no conditions will be applied
    #   in this scope
    # @param [Numeric] radius The distance *in miles* around the coordinates
    #   that will be searched
    # @param [String] column The name of the geographic column, defaults
    #   to 'coordinates'
    # @return [School::ActiveRecord_Relation] All matching records
    scope :close_to, lambda { |point, radius: DEFAULT_RADIUS, column: 'coordinates', include_distance: true|
      if point.present?
        query = where(sprintf("st_dwithin(%<column>s, '%<coordinates>s', %<radius>d)", column: column, coordinates: point, radius: Conversions::Distance::Miles::ToMetres.convert(radius || DEFAULT_RADIUS)))

        if include_distance
          return query.select(
            [
              arel_table[Arel.star],
              sprintf("st_distance(%<source>s, '%<destination>s', false) as distance", source: column, destination: point)
            ]
          )
        end

        query
      else
        none
      end
    }
  end
end
