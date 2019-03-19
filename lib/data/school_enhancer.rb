# SchoolEnhancer should be run following the SchoolImporter
#
# It uses our gathered data to fill in additional information
# about Bookings::School objects, including subjects.
class SchoolEnhancer
  attr_accessor :response_data

  REQUIRED_HEADERS = %w{
    urn secondary_subjects easter_availability school_experience_description
    primary_key_stage_details teacher_training_details itt_website
    school_experience_availability_details
  }.freeze

  def initialize(raw_response_data)
    # read the file using the headers defined above
    # drop the header line as we're using our own shorter ones
    self.response_data = raw_response_data

    unless (REQUIRED_HEADERS & self.response_data.headers) == REQUIRED_HEADERS
      fail "Missing fields: #{REQUIRED_HEADERS - self.response_data.headers}"
    end
  end

  def enhance
    Bookings::School.transaction do
      total = response_data.size

      response_data.each.with_index(1) do |row, i|
        urn = extract_urn(row['urn'])

        school = Bookings::School.find_by(urn: urn)

        if school.nil?
          Rails.logger.warn("No existing school found with URN: #{urn}")
          next
        end

        school.update_attributes(
          availability_info: cleanse_text(row['school_experience_availability_details']),
          placement_info: cleanse_text(row['school_experience_description']),
          primary_key_stage_info: cleanse_text(row['primary_key_stage_details']),
          teacher_training_info: cleanse_text(row['teacher_training_details']),
          teacher_training_provider: row['teacher_training_details'].present?,
          teacher_training_website: row['itt_website']
        )

        if row['secondary_subjects'].present?
          school.subjects << extract_secondary_subjects(row['secondary_subjects'])
        end

        puts "#{i} of #{total} #{school.name} enhanced"
      end
    end
  end

private

  def secondary_subjects
    @secondary_subjects ||= Bookings::Subject.all.index_by(&:name)
  end

  def extract_urn(raw)
    raw.to_i
  end

  def extract_secondary_subjects(raw)
    secondary_subjects.values_at(*raw.split(', ')).compact
  end

  def cleanse_text(raw)
    raw.remove("\r").strip if raw.present?
  end
end
