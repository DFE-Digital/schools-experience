module Schools
  module PlacementRequests
    class AddMoreDetails
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :contact_name
      attribute :contact_number
      attribute :contact_email
      attribute :location

      validates :contact_name, presence: true
      validates :contact_number, presence: true
      validates :contact_email, presence: true
      validates :contact_email, email_format: true, if: -> { contact_email.present? }
      validates :location, presence: true

      def self.for_school(school)
        return new unless (last_booking = school.bookings.accepted.order(id: 'desc').first)

        new(
          contact_name: last_booking.contact_name,
          contact_number: last_booking.contact_number,
          contact_email: last_booking.contact_email,
          location: last_booking.location
        )
      end
    end
  end
end
