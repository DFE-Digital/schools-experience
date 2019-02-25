class Bookings::SchoolSearch
  attr_accessor :query, :point, :radius, :subjects, :phases, :max_fee, :page, :requested_order

  AVAILABLE_ORDERS = [
    %w{distance Distance},
    %w{fee Fee}
  ].freeze

  def self.available_orders
    AVAILABLE_ORDERS.map
  end

  def initialize(query, location: nil, radius: 10, subjects: nil, phases: nil, max_fee: nil, requested_order: nil, page: nil)
    self.query           = query
    self.point           = parse_location(location)
    self.radius          = radius
    self.subjects        = subjects
    self.phases          = phases
    self.max_fee         = max_fee
    self.page            = page
    self.requested_order = requested_order
  end

  # Note, all of the scopes provided by +Bookings::School+ will not
  # amend the +ActiveRecord::Relation+ if no param is provided, meaning
  # they can be safely chained
  def results
    Bookings::School
      .close_to(@point, radius: @radius)
      .that_provide(@subjects)
      .at_phases(@phases)
      .costing_upto(@max_fee)
      .search(@query)
      .order(order_by(@requested_order))
      .page(@page)
      .includes(%i{subjects phases school_type})
  end

  class InvalidCoordinatesError < ArgumentError
    def initialize(msg = "Invalid coordinates - :latitude or :longitude keys are missing", *args)
      super(msg, *args)
    end
  end

private

  def parse_location(location)
    if location.is_a?(Hash)
      extract_coords(location) || raise(InvalidCoordinatesError)
    elsif location.present?
      geolocate(location)
    end
  end

  def extract_coords(coords)
    coords = coords.symbolize_keys

    if coords.has_key?(:latitude) && coords.has_key?(:longitude)
      Bookings::School::GEOFACTORY.point(
        coords[:longitude],
        coords[:latitude]
      )
    elsif coords.has_key?(:lat)
      if coords.has_key?(:lng)
        Bookings::School::GEOFACTORY.point(coords[:lng], coords[:lat])
      elsif coords.has_key?(:lon)
        Bookings::School::GEOFACTORY.point(coords[:lon], coords[:lat])
      end
    end
  end

  def geolocate(location)
    if (result = Geocoder.search(location)&.first)
      Bookings::School::GEOFACTORY.point(
        result.data.dig('lon'),
        result.data.dig('lat')
      )
    end
  end

  def order_by(requested_order)
    if (requested_order == 'distance') && @point.present?
      # note distance isn't actually an attribute of
      # Bookings::School so we can't use hash syntax
      # as Rails will complain
      'distance asc'
    elsif requested_order == 'fee'
      { fee: 'asc' }
    elsif requested_order == 'name'
      { name: 'asc' }
    else # revert to pg_search's rank which is default
      {}
    end
  end
end
