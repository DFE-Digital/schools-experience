class Bookings::SchoolSearch < ApplicationRecord
  attr_accessor :requested_order
  attr_reader :location_name

  validates :location, length: { minimum: 3 }, allow_nil: true

  AVAILABLE_ORDERS = [
    %w{distance Distance},
    %w{name Name}
  ].freeze

  REGION = 'England'.freeze
  GEOCODER_PARAMS = { maxRes: 1 }.freeze

  def self.available_orders
    AVAILABLE_ORDERS.map
  end

  def initialize(attributes = {})
    # location can be passed in as a hash or a string, we don't want to write a
    # hash to a string field so wipe it if necessary.
    @location_attribute = attributes[:location]
    attributes[:location] = nil if @location_attribute.is_a?(Hash)

    super

    self.coordinates = parse_location(@location_attribute)
  end

  def results
    base_query
      .includes(%i{subjects phases})
      .reorder(order_by(requested_order))
      .page(self.page)
  end

  def total_count
    base_query(include_distance: false).count.tap do |count|
      save_with_result_count(count)
    end
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

  def save_with_result_count(count)
    self.number_of_results = count
    save
  end

  # Note, all of the scopes provided by +Bookings::School+ will not
  # amend the +ActiveRecord::Relation+ if no param is provided, meaning
  # they can be safely chained
  def base_query(include_distance: true)
    Bookings::School
      .close_to(coordinates, radius: radius, include_distance: include_distance)
      .that_provide(subjects)
      .at_phases(phases)
      .costing_upto(max_fee)
      .enabled
      .with_availability
      .distinct
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
    result = Geocoder.search(
      [location, REGION].join(", "),
      params: GEOCODER_PARAMS
    )&.first

    if empty_geocoder_result?(result)
      Rails.logger.info("No Geocoder results found in #{REGION} for #{location}")
      return
    end

    fail InvalidGeocoderResultError unless valid_geocoder_result?(result)

    @location_name = result.name
    extract_coords(latitude: result.latitude, longitude: result.longitude)
  end

  def empty_geocoder_result?(result)
    result.blank? || result.try(:name) == REGION
  end

  def valid_geocoder_result?(result)
    result.is_a?(Geocoder::Result::Base) &&
      result.longitude.present? &&
      result.latitude.present?
  end

  def order_by(option)
    if (option == 'distance') && coordinates.present?
      # note distance isn't actually an attribute of
      # Bookings::School so we can't use hash syntax
      # as Rails will complain
      'distance asc'
    else
      { name: 'asc' }
    end
  end
end
