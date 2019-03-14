# SchoolEnhancer should be run following the SchoolImporter
#
# It uses our gathered data to fill in additional information
# about Bookings::School objects, including subjects.
class SchoolEnhancer
  def initialize(response_data)
    @response_data = response_data
  end

  def enhance
    Bookings::School.transaction do
      total = @response_data.size

      @response_data.each.with_index(1) do |row, i|
        urn = extract_urn(row[:urn])

        school = Bookings::School.find_by(urn: urn)

        if school.nil?
          Rails.logger.warn("No school found with URN: #{urn}")
          next
        end

        school.school_experience_description = cleanse_text(row[:school_experience_description])
        school.teacher_training_provider = row[:teacher_training_details].present?
        school.teacher_training_details = cleanse_text(row[:teacher_training_details])
        school.primary_key_stage_details = cleanse_text(row[:primary_key_stage_details])
        school.school_experience_availability_details = cleanse_text(row[:school_experience_availability_details])
        school.website = row[:website]

        school.save

        if row[:secondary_subjects].present?
          school.subjects << extract_secondary_subjects(row[:secondary_subjects])
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
    #raw.delete('\r').strip if raw.present?
    raw.remove("\r").strip if raw.present?
  end
end
