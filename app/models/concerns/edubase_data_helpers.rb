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

  def cleanup_website(edubase_row)
    urn = edubase_row['URN'].to_i
    url = edubase_row['SchoolWebsite']

    return nil if url.blank?

    raise "invalid hostname for #{urn}, #{url}" unless url.split(".").size > 1

    # do nothing if starting with a valid protocol
    url_with_prefix = if url.starts_with?("http:", "https:")
                        url

                        # typos
                      elsif url.starts_with?("http;")
                        url.tr('http;', 'http:')

                      elsif url.starts_with?("Hhtp:")
                        url.tr('Hhtp:', 'http:')

                        # add a prefix if none present, most common error
                      else
                        "http://#{url}"
                      end

    # skip ip addresses
    return nil if url_with_prefix =~ /\d+\.\d+\.\d+\.\d+/

    # skip email addresses
    return nil if url_with_prefix =~ /@/

    # skip urls that don't look sensible
    unless url_with_prefix.match?(/^(http|https):\/\/[a-z0-9]+([\-.]{1}[a-z0-9]+)*\.[a-z]{2,10}(:[0-9]{1,5})?(\/.*)?$/ix)
      Rails.logger.info "invalid website for #{urn}, #{url}"
      return nil
    end

    url_with_prefix.downcase
  end
end
