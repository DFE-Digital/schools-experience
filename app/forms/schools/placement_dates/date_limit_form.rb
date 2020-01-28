module Schools
  module PlacementDates
    class DateLimitForm
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :max_bookings_count, :integer
      validates :max_bookings_count,
        numericality: { greater_than: 0, only_integer: true, allow_nil: true },
        presence: true

      def self.new_from_date(placement_date)
        new max_bookings_count: placement_date.max_bookings_count
      end

      def save(placement_date)
        return false unless valid?

        Bookings::PlacementDate.transaction do
          assign_attributes_to_placement_date placement_date
          placement_date.save!
        end
      end

    private

      def assign_attributes_to_placement_date(placement_date)
        placement_date.max_bookings_count = self.max_bookings_count
        placement_date.published_at = DateTime.now
      end
    end
  end
end
