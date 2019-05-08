require 'breasal'

# SchoolImporter takes raw data from TPUK and EduBase and combines them to
# create Bookings::School (and associated) objects.
#
# If any validation fails (including if the URNs provided in the TPUK dataset
# already exist), the whole import will fail and roll back.
class SchoolImporter
  attr_accessor :tpuk_data, :edubase_data, :email_override
  def initialize(tpuk_data, edubase_data, email_override = nil)
    self.tpuk_data = tpuk_data
      .reject { |l| l['urn'].in?(%w{URN SCITT TRUST TSA ??????}) }
      .each
      .with_object({}) do |record, h|
        h[record['urn'].to_i] = record
      end

    self.edubase_data = edubase_data
      .each
      .with_object({}) do |record, h|
        h[record['URN'].to_i] = record
      end

    self.email_override = email_override
  end

  def import
    total = @tpuk_data.length

    Bookings::School.transaction do
      @tpuk_data.each.with_index(1) do |(urn, tpuk_row), i|
        unless (edubase_row = @edubase_data[urn])
          raise "URN #{urn} cannot be found in dataset"
        end

        if build_school(edubase_row, tpuk_row).save
          unless Rails.env.test?
            puts("%<count>s of %<total>d | %<urn>s | %<name>s" % {
              count: i.to_s.rjust(3),
              total: total,
              urn: urn.to_s.rjust(8),
              name: edubase_row['EstablishmentName']
            })
          end
        else
          fail "failed to import #{urn}"
        end
      end
    end
  end

private

  def build_school(edubase_row, tpuk_row)
    Bookings::School.new(
      urn:           nilify(edubase_row['URN']),
      name:          nilify(edubase_row['EstablishmentName']),
      website:       cleanup_website(edubase_row['URN'], edubase_row['SchoolWebsite']),
      contact_email: email_override.present? ? email_override : nilify(tpuk_row['contact_email'])&.downcase,
      address_1:     nilify(edubase_row['Street']),
      address_2:     nilify(edubase_row['Locality']),
      address_3:     nilify(edubase_row['Address3']),
      town:          nilify(edubase_row['Town']),
      county:        nilify(edubase_row['County (name)']),
      postcode:      nilify(edubase_row['Postcode']),
      coordinates:   convert_to_point(edubase_row['Easting'], edubase_row['Northing']),
      school_type:   school_types[edubase_row['TypeOfEstablishment (code)'].to_i]
    ).tap do |school|
      assign_phases(school, edubase_row['PhaseOfEducation (code)'].to_i)
    end
  end

  def cleanup_website(urn, url)
    return nil unless url.present?

    fail "invalid hostname for #{urn}, #{url}" unless url.split(".").size > 1

    # add a prefix if none present, most common error
    url_with_prefix = if url.starts_with?("http")
                        url
                      else
                        "http://#{url}"
                      end

    fail "invalid website for #{urn}, #{url}" unless url_with_prefix =~ URI::regexp(%w(http https))

    url_with_prefix.downcase
  end

  def nilify(val)
    val.present? ? val.strip : nil
  end

  def assign_phases(school, edubase_id)
    overrides = {
      105271 => 4
    }
    if (p = map_phase(overrides.has_key?(school.urn) ? overrides.fetch(school.urn) : edubase_id))
      school.phases << p
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
