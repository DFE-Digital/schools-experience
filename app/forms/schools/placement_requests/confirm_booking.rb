module Schools
  module PlacementRequests
    class ConfirmBooking
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :date
      attribute :placement_details
      attribute :bookings_subject_id

      validates :date, presence: true
      validates :placement_details, presence: true
      validates :bookings_subject_id, presence: true
    end
  end
end
