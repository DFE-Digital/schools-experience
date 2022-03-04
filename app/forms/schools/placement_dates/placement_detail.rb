module Schools
  module PlacementDates
    class PlacementDetail
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :start_availability_offset
      attribute :end_availability_offset
      attribute :duration
      attribute :virtual, :boolean
      attribute :supports_subjects, :boolean
      attribute :school_has_primary_and_secondary_phases, :boolean

      validates :start_availability_offset, presence: true, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 180 }
      validates :end_availability_offset, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
      validates :duration, presence: true, numericality: { greater_than_or_equal_to: 1, less_than: 100 }
      validates :virtual, inclusion: [true, false]
      # users manually selecting this only happens when schools are both primary
      # and secondary, otherwise it's automatically set in the controller
      validates :supports_subjects, inclusion: [true, false], if: -> { school_has_primary_and_secondary_phases }
      validate :start_offset_greater_than_end_offset

      def self.new_from_date(placement_date)
        new(
          start_availability_offset: placement_date.start_availability_offset,
          end_availability_offset: placement_date.end_availability_offset,
          duration: placement_date.duration,
          virtual: placement_date.virtual,
          supports_subjects: placement_date.supports_subjects,
          school_has_primary_and_secondary_phases: placement_date.bookings_school&.has_primary_and_secondary_phases?
        )
      end

      def save(placement_date)
        return false unless valid?

        assign_attributes_to_placement_date placement_date
        placement_date.save!
      end

    private

      def start_offset_greater_than_end_offset
        return if start_availability_offset.nil? || end_availability_offset.nil?

        if start_availability_offset.to_i <= end_availability_offset.to_i
          errors.add(:start_availability_offset, "The publish date must be before the closing date")
        end
      end

      def assign_attributes_to_placement_date(placement_date)
        placement_date.start_availability_offset = start_availability_offset
        placement_date.end_availability_offset = end_availability_offset
        placement_date.duration = duration
        placement_date.virtual = virtual
        placement_date.supports_subjects = supports_subjects unless supports_subjects.nil?
      end
    end
  end
end
