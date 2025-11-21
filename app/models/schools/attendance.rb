module Schools
  class Attendance
    include ActiveModel::Model

    attr_accessor :bookings, :bookings_params, :updated_bookings

    def initialize(bookings:, bookings_params:)
      self.bookings = bookings
      self.bookings_params = bookings_params
    end

    def save
      @updated_bookings = []
      bookings_params.each do |booking_key, attended|
        fetch(booking_key).tap do |booking|
          booking.attended = ActiveModel::Type::Boolean.new.cast(attended)
          booking.save!(context: :attendance)
          send_candidate_feedback_email(booking)
          @updated_bookings << booking.id
        rescue ActiveRecord::RecordInvalid => e
          errors.add :bookings_params,
            "Unable to set attendance for #{booking.date.to_formatted_s(:govuk)}"

          update_error e
        end
      end

      errors.empty?
    end

    def update_gitis
      bookings_params.slice(*updated_bookings.map(&:to_s)).each do |booking_key, attended|
        fetch(booking_key).tap do |booking|
          status = ActiveModel::Type::Boolean.new.cast(attended) ? :completed : :did_not_attend
          Bookings::Gitis::SchoolExperience.from_booking(booking, status)
            .write_to_gitis_contact(booking.contact_uuid)
        end
      end
    end

  private

    def send_candidate_feedback_email(booking)
      return unless booking.attended?

      NotifyEmail::CandidateBookingFeedbackRequest
        .from_booking(booking)
        .despatch_later!
    end

    def indexed_bookings
      @indexed_bookings ||= bookings.index_by(&:id)
    end

    def fetch(booking_key)
      indexed_bookings.fetch(booking_key.to_i)
    end

    def update_error(exception)
      Sentry.capture_exception(exception)
    end
  end
end
