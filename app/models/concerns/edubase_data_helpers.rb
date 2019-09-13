module EdubaseDataHelpers
  extend ActiveSupport::Concern

  def convert_to_point(edubase_row)
    easting  = retrive_easting(edubase_row)
    northing = retrieve_northing(edubase_row)

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

  def retrieve_northing(edubase_row)
    edubase_row['Northing'].to_i
  end

  def retrive_easting(edubase_row)
    edubase_row['Easting'].to_i
  end

  def retrieve_school_type(edubase_row)
    edubase_row['TypeOfEstablishment (code)'].to_i
  end
end
