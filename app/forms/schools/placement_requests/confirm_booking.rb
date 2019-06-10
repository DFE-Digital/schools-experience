module Schools
  module PlacementRequests
    class ConfirmBooking
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveRecord::AttributeAssignment

      attribute :date, :date
      attribute :placement_details
      attribute :bookings_subject_id, :integer

      validates :date, presence: true
      validates :placement_details, presence: true
      validates :bookings_subject_id, presence: true

      validate :ensure_date_in_future, if: -> { date.present? }

    private

      def ensure_date_in_future
        if self.date <= Date.today
          errors.add(:date, "must be in the future")
        end
      end
    end
  end
end
