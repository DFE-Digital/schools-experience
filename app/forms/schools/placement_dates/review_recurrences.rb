module Schools
  module PlacementDates
    class ReviewRecurrences
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :dates

      validates :dates, presence: true

      def dates
        super&.map(&:to_date)
      end
    end
  end
end
