require 'breasal'

class SchoolImporter
  attr_accessor :tpuk_data, :edubase_data
  def initialize(tpuk_data, edubase_data)
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
      website:       nilify(edubase_row['SchoolWebsite']),
      contact_email: nilify(tpuk_row['contact_email'])&.downcase,
      address_1:     nilify(edubase_row['Street']),
      address_2:     nilify(edubase_row['Locality']),
      address_3:     nilify(edubase_row['Address3']),
      town:          nilify(edubase_row['Town']),
      county:        nilify(edubase_row['County (name)']),
      postcode:      nilify(edubase_row['Postcode']),
      coordinates:   convert_to_point(edubase_row['Easting'], edubase_row['Northing']),
      school_type:   school_types[edubase_row['TypeOfEstablishment (code)'].to_i]
    ).tap do |school|
      if (p = map_phase(edubase_row['PhaseOfEducation (code)'].to_i))
        school.phases << p
      end
    end
  end

  def nilify(val)
    val.present? ? val.strip : nil
  end

  def map_phase(edubase_id)
    # 0: Not applicable              -> ¯\_(ツ)_/¯
    # 1: Nursery                     -> Nursery
    # 2: Primary                     -> Primary
    # 3: Middle deemed primary       -> Primary
    # 4: Secondary                   -> Secondary
    # 5: Middle deemed secondary     -> Secondary
    # 6: 16 plus                     -> 16 plus
    # 7: All through                 -> Nursery + Primary + Secondary + 16 plus

    nursery      = phases['Nursery']
    primary      = phases['Primary']
    secondary    = phases['Secondary']
    sixteen_plus = phases['16 plus']

    {
      1 => nursery,
      2 => primary,
      3 => primary,
      4 => secondary,
      5 => secondary,
      6 => sixteen_plus,
      7 => [nursery, primary, secondary, sixteen_plus]
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
