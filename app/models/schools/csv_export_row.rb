module Schools
  class CsvExportRow
    attr_reader :request

    delegate :placement_date, :viewed?, :booking, :status,
              :candidate_cancellation, :school_cancellation, to: :request

    def initialize(request)
      @request = request
    end

    def row
      [
        request.id,
        name,
        email,
        date,
        duration,
        subject,
        status,
        attendance
      ]
    end

  private

    def name
      request.candidate.full_name || "Unavailable"
    end

    def email
      request.candidate.gitis_contact&.email || "Unavailable"
    end

    def date
      (booking || placement_date)&.date&.to_formatted_s(:govuk)
    end

    def duration
      (booking || placement_date)&.duration
    end

    def subject
      if booking
        booking.bookings_subject.name
      else
        request.subject&.name || request.subject_first_choice
      end
    end

    def attendance
      case booking&.attended
      when true
        "Attended"
      when false
        "Did not attend"
      end
    end
  end
end
