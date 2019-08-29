module Schools
  module PlacementDates
    class SubjectSelection
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :available_for_all_subjects, :boolean
      attr_reader :subject_ids

      validates :subject_ids, presence: true, unless: :available_for_all_subjects

      def self.new_from_date(placement_date)
        if placement_date.published?
          new \
            available_for_all_subjects: !placement_date.subject_specific?,
            subject_ids: placement_date.subject_ids
        else
          new
        end
      end

      def subject_ids=(array)
        @subject_ids = Array.wrap(array).reject(&:blank?)
      end

      def save(placement_date)
        return false unless valid?

        if available_for_all_subjects
          placement_date.subject_specific = false
          placement_date.subject_ids = []
        else
          placement_date.subject_specific = true
          placement_date.subject_ids = self.subject_ids
        end

        placement_date.published_at = DateTime.now

        placement_date.save!
      end
    end
  end
end
