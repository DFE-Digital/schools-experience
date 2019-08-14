module BookingsDataHelpers
  extend ActiveSupport::Concern

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

  def school_types
    @school_types ||= Bookings::SchoolType.all.index_by(&:edubase_id)
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
