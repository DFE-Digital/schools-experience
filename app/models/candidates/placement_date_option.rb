class Candidates::PlacementDateOption
  # Show what subjects are on offer for a given date
  def self.for_secondary_date(placement_date)
    if placement_date.placement_date_subjects.any?
      placement_date.placement_date_subjects.map do |placement_date_subject|
        new(
          placement_date_subject.date_and_subject_id,
          placement_date_subject.bookings_subject.name,
          placement_date.duration,
          placement_date.date
        )
      end
    else
      Array.wrap(
        new(
          placement_date.id,
          'All subjects',
          placement_date.duration,
          placement_date.date
        )
      )
    end
  end

  attr_accessor :id, :name, :duration, :date

  def initialize(id, name, duration, date)
    @id = id
    @name = name
    @duration = duration
    @date = date
  end

  def name_with_duration
    "#{name} (#{duration} #{'day'.pluralize(duration)})"
  end

  # Sorted here rather than in the db so 'All subjects' (which isn't in the DB)
  # comes back first
  def <=>(other)
    name <=> other.name
  end
end
