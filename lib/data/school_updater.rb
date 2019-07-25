require 'breasal'

class SchoolUpdater
  BATCH_SIZE = 1000

  ATTRIBUTE_MAPPING = {
    name: 'EstablishmentName',
    address_1: 'Street',
    address_2: 'Locality',
    address_3: 'Address 3',
    town: 'Town',
    county: 'County (name)',
    postcode: 'Postcode'
  }.freeze

  attr_accessor :edubase_data

  def initialize(edubase_data)
    self.edubase_data = edubase_data
      .each
      .with_object({}) do |record, h|
        h[record['URN'].to_i] = record
      end
  end

  def update
    Bookings::School.eager_load(:school_type).find_each(batch_size: BATCH_SIZE) do |school|
      Bookings::School.transaction do
        row = edubase_data[school.urn]

        next if row.nil?
        next if matches?(school, row)

        school.update(build_attributes(row))
        Event.create(bookings_school: school, event_type: 'school_edubase_data_refreshed')
      end
    end
  end

private

  def school_types
    @school_types ||= Bookings::SchoolType.all.index_by(&:edubase_id)
  end

  def matches?(school, row)
    [
      attributes_match?(school, row),
      coords_match?(school, row),
      school_types_match?(school, row)
    ].all?
  end

  def attributes_match?(school, row)
    ATTRIBUTE_MAPPING.map { |k, v| school.send(k).presence == row[v].presence }.all?
  end

  def coords_match?(school, row)
    school.coordinates == convert_to_point(row)
  end

  def school_types_match?(school, row)
    school.school_type.edubase_id == retrieve_school_type(row)
  end

  def build_attributes(row)
    ATTRIBUTE_MAPPING.each_with_object({}) { |(k, v), h| h[k] = row[v] }.tap do |attrs|
      attrs.merge(coordinates: convert_to_point(row))
      attrs.merge(school_type_id: school_types[row[retrieve_school_type(row)]])
    end
  end

  def convert_to_point(row)
    easting  = retrive_easting(row)
    northing = retrieve_northing(row)

    return nil if easting.blank? || northing.blank?

    coords = Breasal::EastingNorthing.new(
      easting: easting,
      northing: northing,
      type: 'gb'
    ).to_wgs84

    Bookings::School::GEOFACTORY.point(coords[:longitude], coords[:latitude])
  end

  def retrieve_northing(row)
    row['Northing'].to_i
  end

  def retrive_easting(row)
    row['Easting'].to_i
  end

  def retrieve_school_type(row)
    row['TypeOfEstablishment (code)'].to_i
  end
end
