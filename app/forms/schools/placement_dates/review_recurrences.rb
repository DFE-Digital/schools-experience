module Schools
  module PlacementDates
    class ReviewRecurrences
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :dates
      attribute :start_at

      validates :dates, presence: true

      def dates
        super&.map(&:to_date)
      end

      def start_at
        dates.first
      end

      def dates_as_string
        dates.join(", ")
      end
    end
  end
end
