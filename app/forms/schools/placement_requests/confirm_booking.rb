module Schools
  module PlacementRequests
    class ConfirmBooking
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveRecord::AttributeAssignment

      attribute :date, :date
      attribute :placement_details
      attribute :bookings_subject_id, :integer

      validates :date,
        timeliness: {
          on_or_after: :today,
          before: -> { 2.years.from_now },
          type: :date
        },
        presence: true
      validates :placement_details, presence: true
      validates :bookings_subject_id, presence: true
    end
  end
end
