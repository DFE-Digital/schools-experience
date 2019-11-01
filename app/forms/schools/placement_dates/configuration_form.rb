module Schools
  module PlacementDates
    class ConfigurationForm
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :max_bookings_count, :integer
      attribute :has_limited_availability, :boolean
      attribute :available_for_all_subjects, :boolean
      attribute :supports_subjects, :boolean

      validates :max_bookings_count, numericality: { greater_than: 0 }, if: :has_limited_availability
      validates :max_bookings_count, absence: true, unless: :has_limited_availability
      validates :has_limited_availability, inclusion: [true, false]
      validates :supports_subjects, inclusion: [true, false]
      validates :available_for_all_subjects, inclusion: [true, false], if: :supports_subjects

      def self.new_from_date(placement_date)
        # Default fields to unselected
        if placement_date.published?
          new \
            max_bookings_count: placement_date.max_bookings_count,
            has_limited_availability: placement_date.has_limited_availability?,
            available_for_all_subjects: !placement_date.subject_specific?,
            supports_subjects: placement_date.supports_subjects?
        else
          new
        end
      end

      def save(placement_date)
        ux_fix
        return false unless valid?

        assign_attributes_to_placement_date placement_date
        placement_date.save!
      end

      def subject_specific?
        supports_subjects && !available_for_all_subjects
      end

    private

      # allow user to avoid having to clear max_bookings_count field if
      # selecting false for has_limited_availability
      def ux_fix
        self.max_bookings_count = nil unless has_limited_availability
      end

      def assign_attributes_to_placement_date(placement_date)
        placement_date.max_bookings_count = max_bookings_count

        if subject_specific?
          placement_date.subject_specific = true
          # Unpublish the date if we're editing, the next step will publish it
          placement_date.published_at = nil
        else
          placement_date.subject_specific = false
          placement_date.subject_ids = []
          placement_date.published_at = DateTime.now
        end
      end
    end
  end
end
