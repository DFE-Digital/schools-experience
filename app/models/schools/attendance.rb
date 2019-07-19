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
        self.bookings_params.each do |booking_id, attended|
          self.bookings.index_by(&:id).fetch(booking_id).tap do |booking|
            booking.update(attended: ActiveModel::Type::Boolean.new.cast(attended))
          end
        end
      end
    end
  end
end
