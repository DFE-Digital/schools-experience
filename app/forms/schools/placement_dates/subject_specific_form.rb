module Schools
  module PlacementDates
    class SubjectSpecificForm
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :available_for_all_subjects, :boolean
      attribute :supports_subjects, :boolean

      validates :supports_subjects, inclusion: [true, false]
      validates :available_for_all_subjects, inclusion: [true, false], if: :supports_subjects

      def self.new_from_date(placement_date)
        # Default fields to unselected
        if placement_date.published?
          new \
            available_for_all_subjects: !placement_date.subject_specific?,
            supports_subjects: placement_date.supports_subjects?
        else
          new
        end
      end

      def save(placement_date)
        return false unless valid?

        Bookings::PlacementDate.transaction do
          assign_attributes_to_placement_date placement_date
          placement_date.save!
        end
      end

      def subject_specific?
        supports_subjects && !available_for_all_subjects
      end

    private

      def assign_attributes_to_placement_date(placement_date)
        placement_date.published_at = nil
        placement_date.subject_ids = [] unless subject_specific?
        placement_date.subject_specific = subject_specific?

        true
      end
    end
  end
end
