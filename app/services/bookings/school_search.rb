class Bookings::SchoolSearch
  attr_accessor :query, :point, :radius, :subjects, :phases, :max_fee, :page, :requested_order

  AVAILABLE_ORDERS = [
    %w{distance Distance},
    %w{name Name}
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

  def results
    base_query
      .includes(%i{subjects phases})
      .reorder(order_by(@requested_order))
      .page(@page)
  end

  def total_count
    base_query(include_distance: false).count
  end

  class InvalidCoordinatesError < ArgumentError
    def initialize(msg = "Invalid coordinates - :latitude or :longitude keys are missing", *args)
      super(msg, *args)
    end
  end

  class InvalidGeocoderResultError < ArgumentError
    def initialize(msg = "Invalid geocoder result - :latitude or :longitude keys are missing", *args)
      super(msg, *args)
    end
  end

private

  # Note, all of the scopes provided by +Bookings::School+ will not
  # amend the +ActiveRecord::Relation+ if no param is provided, meaning
  # they can be safely chained
  def base_query(include_distance: true)
    Bookings::School
      .close_to(@point, radius: @radius, include_distance: include_distance)
      .that_provide(@subjects)
      .at_phases(@phases)
      .costing_upto(@max_fee)
      .search(@query)
  end

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
    result = Geocoder.search(location)&.first

    if result.blank?
      Rails.logger.info("No Geocoder results found for #{location}")
      return
    end

    fail InvalidGeocoderResultError unless valid_geocoder_result?(result)

    extract_coords(latitude: result.latitude, longitude: result.longitude)
  end

  def valid_geocoder_result?(result)
    result.is_a?(Geocoder::Result::Base) &&
      result.longitude.present? &&
      result.latitude.present?
  end

  def order_by(requested_order)
    if (requested_order == 'distance') && @point.present?
      # note distance isn't actually an attribute of
      # Bookings::School so we can't use hash syntax
      # as Rails will complain
      'distance asc'
    else
      { name: 'asc' }
    end
  end
end
