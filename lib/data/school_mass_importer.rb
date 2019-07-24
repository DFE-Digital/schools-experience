require 'breasal'
require 'activerecord-import'

class SchoolMassImporter
  attr_accessor :existing_urns, :edubase_data, :email_override

  def initialize(edubase_data, email_override = nil)
    self.edubase_data = edubase_data
      .each
      .with_object({}) do |record, h|
        h[record['URN'].to_i] = record
      end

    self.email_override = email_override

    self.existing_urns = Bookings::School.pluck(:urn)
  end

  def import
    data = edubase_data
        .reject { |urn, _| urn.in?(existing_urns) }
        .map { |_, v| build_school(v) }
        .compact

    Bookings::School.transaction do
      puts "importing schools..."
      Bookings::School.import(data)

      puts "setting up phases..."
      edubase_data.each.with_index do |(urn, row), i|
        if (i % 1000).zero?
          print '.'
        end

        assign_phases(urn, row['PhaseOfEducation (code)'])
      end

      puts "done..."
    end
  end

private

  def assign_phases(urn, edubase_id)
    phases = map_phase(edubase_id.to_i)
    return if phases.nil?

    Bookings::School.find_by(urn: urn).tap do |school|
      school.phases << phases if school
    end
  end

  def map_phase(edubase_id)
    # 0: Not applicable              -> ¯\_(ツ)_/¯
    # 1: Nursery                     -> Early years
    # 2: Primary                     -> Primary (4 to 11)
    # 3: Middle deemed primary       -> Primary (4 to 11)
    # 4: Secondary                   -> Secondary (11 to 16)
    # 5: Middle deemed secondary     -> Secondary (11 to 16)
    # 6: 16 plus                     -> 16 to 18
    # 7: All through                 -> Nursery + Primary + Secondary + College

    nursery   = phases['Early years']
    primary   = phases['Primary (4 to 11)']
    secondary = phases['Secondary (11 to 16)']
    college   = phases['16 to 18']

    {
      1 => nursery,
      2 => primary,
      3 => primary,
      4 => secondary,
      5 => secondary,
      6 => college,
      7 => [nursery, primary, secondary, college]
    }[edubase_id]
  end

  def phases
    @phases ||= Bookings::Phase.all.index_by(&:name)
  end

  def nilify(val)
    val.present? ? val.strip : nil
  end

  def cleanup_website(urn, url)
    return nil unless url.present?

    fail "invalid hostname for #{urn}, #{url}" unless url.split(".").size > 1

                      # add a prefix if none present, most common error
    url_with_prefix = if url.starts_with?("http:")
                        url
                      # one school has a typo...
                      elsif url.starts_with?("http;")
                        url.tr('http;', 'http:')
                      else
                        "http://#{url}"
                      end

    fail "invalid website for #{urn}, #{url}" unless url_with_prefix =~ URI::regexp(%w(http https))

    url_with_prefix.downcase
  end

  def build_school(edubase_row)
    attributes = {
      urn:           nilify(edubase_row['URN']),
      name:          nilify(edubase_row['EstablishmentName']),
      website:       cleanup_website(edubase_row['URN'], edubase_row['SchoolWebsite']),
      contact_email: email_override.present? ? email_override : nil,
      address_1:     nilify(edubase_row['Street']),
      address_2:     nilify(edubase_row['Locality']),
      address_3:     nilify(edubase_row['Address3']),
      town:          nilify(edubase_row['Town']),
      county:        nilify(edubase_row['County (name)']),
      postcode:      nilify(edubase_row['Postcode']),
      coordinates:   convert_to_point(edubase_row['Easting'], edubase_row['Northing']),
      bookings_school_type_id:   school_types[edubase_row['TypeOfEstablishment (code)'].to_i].id
    }

    if attributes[:postcode].blank?
      puts "#{attributes[:urn]}: cannot import #{attributes[:name]}, missing postcode"
      return nil
    end

    if attributes[:address_1].blank?
      puts "#{attributes[:urn]}: cannot import #{attributes[:name]}, missing address_1"
      return nil
    end

    if attributes[:coordinates].blank?
      puts "#{attributes[:urn]}: cannot import #{attributes[:name]}, missing coordinates"
      return nil
    end

    attributes
  end

  def school_types
    @school_types ||= Bookings::SchoolType.all.index_by(&:edubase_id)
  end

  def convert_to_point(easting, northing)
    return nil if easting.blank? || northing.blank?

    coords = Breasal::EastingNorthing.new(
      easting: easting.to_i,
      northing: northing.to_i,
      type: 'gb'
    ).to_wgs84
    Bookings::School::GEOFACTORY.point(coords[:longitude], coords[:latitude])
  end
end
