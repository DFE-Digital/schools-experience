require 'breasal'

class SchoolImporter
  attr_accessor :urns, :edubase_data
  def initialize(urns, edubase_data)
    self.urns = urns
      .reject { |l| l.in?(%w{URN SCITT TRUST TSA}) }
      .map(&:strip)
      .map(&:to_i)

    self.edubase_data = edubase_data
      .each
      .with_object({}) do |record, h|
        h[record['URN'].to_i] = record
      end
  end

  def import
    total = @urns.length

    Bookings::School.transaction do
      @urns.each.with_index(1) do |urn, i|
        unless (row = @edubase_data[urn])
          raise "URN #{urn} cannot be found in dataset"
        end

        if build_school(row).save
          if Rails.env != 'test'
            puts("%<count>s of %<total>d | %<urn>s | %<name>s" % {
              count: i.to_s.rjust(3),
              total: total,
              urn: urn.to_s.rjust(8),
              name: row['EstablishmentName']
            })
          end
        else
          fail "failed to import #{urn}"
        end
      end
    end
  end

private

  def build_school(row)
    Bookings::School.new(
      urn:          nilify(row['URN']),
      name:         nilify(row['EstablishmentName']),
      website:      nilify(row['SchoolWebsite']),
      address_1:    nilify(row['Street']),
      address_2:    nilify(row['Locality']),
      address_3:    nilify(row['Address3']),
      town:         nilify(row['Town']),
      county:       nilify(row['County (name)']),
      postcode:     nilify(row['Postcode']),
      coordinates:  convert_to_point(row['Easting'], row['Northing']),
      school_type:  school_types[row['TypeOfEstablishment (code)'].to_i]
    ).tap do |school|
      school.phases << phases[row['PhaseOfEducation (code)'].to_i]
    end
  end

  def nilify(val)
    val.present? ? val : nil
  end

  def phases
    @phases ||= Bookings::Phase.all.index_by(&:edubase_id)
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
