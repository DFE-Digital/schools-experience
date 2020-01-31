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

      bookings_params.each do |booking_id, attended|
        fetch(booking_id).tap do |booking|
          begin
            booking.update! attended: ActiveModel::Type::Boolean.new.cast(attended)
            @updated_bookings << booking.id
          rescue ActiveRecord::RecordInvalid => e
            errors.add :bookings_params,
              "Unable to set attendance for #{booking.date.to_formatted_s(:govuk)}"

            update_error e
          end
        end
      end

      errors.empty?
    end

    def update_gitis
      bookings_params.slice(*updated_bookings).each do |booking_id, _attended|
        fetch(booking_id).tap do |booking|
          Bookings::Gitis::EventLogger.write_later \
            booking.contact_uuid, :attendance, booking
        end
      end
    end

  private

    def indexed_bookings
      @indexed_bookings ||= self.bookings.index_by(&:id)
    end

    def fetch(id)
      indexed_bookings.fetch(id)
    end

    def update_error(exception)
      ExceptionNotifier.notify_exception(exception)
      Raven.capture_exception(exception)
    end
  end
end
