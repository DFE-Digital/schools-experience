module Schools
  class AttendanceRecords
    attr_reader :candidate_id, :school_urns

    def initialize(candidate_id, school_urns)
      @candidate_id = candidate_id
      @school_urns = school_urns
    end

    def any_stats?
      stats.any?
    end

    def attended_count
      stats[true].to_i
    end

    def did_not_attend_count
      stats[false].to_i
    end

    def records
      attendance_scope
    end

    def stats
      @stats ||= attendance_scope.group(:attended).count(:id)
    end

  private

    def attendance_scope
      Bookings::Booking \
        .joins(:bookings_school, :bookings_placement_request)
        .merge(Bookings::School.where(urn: school_urns))
        .where.not(attended: nil)
        .merge(Bookings::PlacementRequest.where(candidate_id: candidate_id))
    end
  end
end
