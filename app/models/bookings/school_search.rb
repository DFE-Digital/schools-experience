require 'geocoding_request'
require 'geocoding_response_country'

class Bookings::SchoolSearch < ApplicationRecord
  attr_reader :location_name, :location_attribute, :country

  # NB: location could be a string (e.g. "Bury"), a hash in location_attribute (e.g. {:latitude=>"53.593", :longitude=>"-2.289"}) or nil if query is set
  # validates :location, presence: true, unless: -> { [query].any? }
  validates :location, length: { minimum: 2 }, if: -> { location.is_a?(String) }
  validate :location_query_validator

  def location_query_validator
    unless [location, location_attribute, query].any?
      errors.add(:location, :blank)
    end
  end

  # Despite this being an England-only service, we want to search the whole of the UK
  # so that we can return results to users who are near the border.
  REGION = 'United Kingdom'.freeze
  GEOCODER_PARAMS = { maxRes: 1 }.freeze
  PER_PAGE = 15

  class << self
    def whitelisted_urns
      return [] if ENV['CANDIDATE_URN_WHITELIST'].blank?

      ENV['CANDIDATE_URN_WHITELIST'].to_s.strip.split(%r{[\s,]+}).map(&:to_i)
    end

    def whitelisted_urns?
      whitelisted_urns.any?
    end
  end

  delegate :whitelisted_urns, :whitelisted_urns?, to: :class

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
      .includes(%i[phases])
      .order(order_by_distance)
      .page(page)
      .per(PER_PAGE)
  end

  def phase_count(phase_id)
    @phase_count ||= base_query(include_distance: false)
      .unscope(where: { bookings_schools_phases: :bookings_phase_id })
      .joins(:bookings_schools_phases)
      .group("bookings_schools_phases.bookings_phase_id")
      .count

    @phase_count[phase_id] || 0
  end

  def subject_count(subject_id)
    @subject_count ||= base_query(include_distance: false)
      .unscope(where: { bookings_schools_subjects: :bookings_subject_id })
      .joins(:bookings_schools_subjects)
      .group("bookings_schools_subjects.bookings_subject_id")
      .count

    @subject_count[subject_id] || 0
  end

  def dbs_not_required_count
    @dbs_count ||= base_query(include_distance: false)
      .unscope(where: { bookings_profiles: :dbs_policy_conditions })
      .group("bookings_profiles.dbs_policy_conditions")
      .count

    @dbs_count.slice("notrequired", "inschool").values.sum || 0
  end

  def disability_confident_count
    @disability_confident_count ||= base_query(include_distance: false)
      .unscope(where: { bookings_profiles: :disability_confident })
      .group("bookings_profiles.disability_confident")
      .count

    @disability_confident_count[true] || 0
  end

  def parking_count
    @parking_count ||= base_query(include_distance: false)
      .unscope(where: { bookings_profiles: :parking_provided })
      .group("bookings_profiles.parking_provided")
      .count

    @parking_count[true] || 0
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

  def has_coordinates?
    coordinates.present?
  end

  def radius=(dist)
    self[:radius] = if whitelisted_urns?
                      1000 # include all whitelisted schools but still order by distance
                    else
                      dist
                    end
  end

private

  def save_with_result_count(count)
    self.number_of_results = count
    save
  rescue ActiveRecord::StatementInvalid => e
    # This is a temporary measure to pin down a PG::CharacterNotInRepertoire exception
    # that is occasionally raised on saving this model. I'm not sure how it gets into
    # this state yet, but I expect its someone/a bot with JS disabled putting unexpected
    # characters into the input field.
    Rails.logger.error({ error: e, details: { location: location, query: query } })

    # Attempt to recover.
    utf8_encoding = Encoding.find("UTF-8")
    self.query = query&.encode(utf8_encoding, invalid: :replace, undef: :replace, replace: "")
    save
  end

  # Note, all of the scopes provided by +Bookings::School+ will not
  # amend the +ActiveRecord::Relation+ if no param is provided, meaning
  # they can be safely chained
  def base_query(include_distance: true)
    whitelisted_base_query
      .close_to(coordinates, radius: radius, include_distance: include_distance)
      .that_provide(subjects)
      .at_phases(phases)
      .costing_upto(max_fee)
      .onboarded
      .enabled
      .with_availability
      .distinct
      .includes([:available_placement_dates])
      .with_dbs_policies(dbs_options)
      .disability_confident(disability_confident)
      .with_parking(parking)
  end

  def whitelisted_base_query
    if whitelisted_urns?
      Bookings::School.where(urn: whitelisted_urns)
    else
      Bookings::School
    end
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

    if coords.key?(:latitude) && coords.key?(:longitude)
      Bookings::School::GEOFACTORY.point(
        coords[:longitude],
        coords[:latitude]
      )
    elsif coords.key?(:lat)
      if coords.key?(:lng)
        Bookings::School::GEOFACTORY.point(coords[:lng], coords[:lat])
      elsif coords.key?(:lon)
        Bookings::School::GEOFACTORY.point(coords[:lon], coords[:lat])
      end
    end
  end

  def geolocate(location)
    geocoding_request = GeocodingRequest.new(location, REGION)
    formatted_request = geocoding_request.format_address
    result = Geocoder.search(
      formatted_request,
      params: GEOCODER_PARAMS
    )&.first

    if empty_geocoder_result?(result)
      Rails.logger.info("No Geocoder results found for #{formatted_request} (user entered: #{location})")
      return
    end

    raise InvalidGeocoderResultError unless valid_geocoder_result?(result)

    @location_name = result.try(:name)

    @country = GeocodingResponseCountry.new(result)

    extract_coords(
      latitude: result.latitude,
      longitude: result.longitude
    )
  end

  def empty_geocoder_result?(result)
    result.blank? || result.try(:name) == REGION
  end

  def valid_geocoder_result?(result)
    result.is_a?(Geocoder::Result::Base) &&
      result.longitude.present? &&
      result.latitude.present?
  end

  def order_by_distance
    # NOTE: distance isn't actually an attribute of
    # Bookings::School so we can't use hash syntax
    # as Rails will complain
    'distance asc'
  end

  def dbs_options
    if dbs_policies.present?
      dbs_policies.map { |i| Bookings::Profile::DBS_POLICY_CONDITIONS[i.to_i] }.push('inschool')
    end
  end
end
