require 'active_support/concern'

module GeographicSearch

  extend ActiveSupport::Concern
  GEOFACTORY = RGeo::Geographic.spherical_factory(srid: 4326)

  included do

    scope :close_to, -> (coordinates, radius: 10, column: 'coordinates') do
      where("st_dwithin(%s, '%s', %d)" % [column, coordinates, miles_to_metres(radius)])
    end

    def self.miles_to_metres(miles)
      miles * 1609.344
    end

  end

end
