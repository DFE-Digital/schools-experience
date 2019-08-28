module Schools
  class Attendance
    include ActiveModel::Model

    attr_accessor :bookings, :bookings_params

    def initialize(bookings:, bookings_params:)
      self.bookings = bookings
      self.bookings_params = bookings_params
    end

    def save
      Bookings::Booking.transaction do
        bookings_params.each do |booking_id, attended|
          fetch(booking_id).tap do |booking|
            booking.update(attended: ActiveModel::Type::Boolean.new.cast(attended))
          end
        end
      end
    end

    def update_gitis
      bookings_params.each do |booking_id, _attended|
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
  end
end
