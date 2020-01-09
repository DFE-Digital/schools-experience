module Schools
  module PlacementDates
    class SubjectSelection
      include ActiveModel::Model
      include ActiveModel::Attributes

      attr_reader :subject_ids

      validates :subject_ids, presence: true

      def self.new_from_date(placement_date)
        new(subject_ids: placement_date.subject_ids)
      end

      def subject_ids=(array)
        @subject_ids = Array.wrap(array).reject(&:blank?)
      end

      def save(placement_date)
        return false unless valid?

        Bookings::PlacementDate.transaction do
          placement_date.tap do |pd|
            pd.subject_specific = true
            pd.subject_ids = self.subject_ids
            pd.published_at = DateTime.now

            pd.save!
          end
        end
      end
    end
  end
end
