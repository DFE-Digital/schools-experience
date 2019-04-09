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

        if school.update_attributes(
          availability_info: format_text(row['school_experience_availability_details']),
          placement_info: format_text(row['school_experience_description']),
          primary_key_stage_info: format_text(row['primary_key_stage_details']),
          teacher_training_info: format_text(row['teacher_training_details']),
          teacher_training_provider: row['teacher_training_details'].present?,
          teacher_training_website: cleanup_website(urn, row['itt_website'])
        )
          if row['secondary_subjects'].present?
            extract_secondary_subjects(row['secondary_subjects'])
              .each { |s| school.subjects << s unless s.in?(school.subjects) }
          end

          puts "#{i} of #{total} #{school.urn} - #{school.name} enhanced"
        else
          fail "#{i} of #{total} #{school.urn} - #{school.name} failed"
        end
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

  def cleanup_website(urn, url)
    return nil unless url.present?
    return nil if url =~ /@/ # we don't want auth info or email addresses

    first_url = url.split(" ").first

    url_with_prefix = if first_url.starts_with?("http")
                        first_url
                      else
                        "http://#{first_url}"
                      end

    if url_with_prefix.match?(URI::regexp(%w(http https)))
      url_with_prefix.downcase
    else
      Rails.logger.warn("invalid website for #{urn}, #{url}")
      nil
    end
  end

  def format_text(raw)
    return nil unless raw.present?

    raw
      .remove("***")                          # remove triple 'highlighting' asterisks
      .gsub("  ", " ")                        # replace double spaces with single
      .remove("\r")                           # remove non-unix return chars
      .remove("•")                            # list char
      .lines
      .map(&:strip)                           # strip off any leading and trailing whitespace
      .each { |l| !l.blank? && l[0] = l[0]&.upcase } # capitalize new paragraphs without affecting subsequent sentences
      .join("\n\n")
      .gsub(/(\d{2})\.(\d{2})\.(\d{2,4})/) {  # fix date format from 01.02.03 to 01/02/03
        "%<day>s/%<month>s/%<year>s" % {      # note we're using string so we needn't worry about padding zeroes
          day: $1,
          month: $2,
          year: $3
        }
      }
  end
end
