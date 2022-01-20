class Schools::OutstandingTasks
  attr_reader :school_urns

  def initialize(school_urns)
    @school_urns = school_urns
  end

  def summarize
    [
      requests_requiring_attention,
      unviewed_withdrawn_requests,
      upcoming_bookings,
      bookings_pending_attendance_confirmation
    ].reduce(&:deep_merge!)
  end

private

  def requests_requiring_attention
    query = schools
      .joins(:placement_requests)
      .merge(Bookings::PlacementRequest.requiring_attention)
      .merge(Bookings::PlacementRequest.unprocessed)

    keyed_total(query, :requests_requiring_attention)
  end

  def unviewed_withdrawn_requests
    query = schools
      .joins(:placement_requests)
      .merge(Bookings::PlacementRequest.withdrawn_but_unviewed.reorder(nil))

    keyed_total(query, :unviewed_withdrawn_requests)
  end

  def upcoming_bookings
    query = schools
      .joins(:bookings)
      .merge(Bookings::Booking.with_unviewed_candidate_cancellation)

    keyed_total(query, :upcoming_bookings)
  end

  def bookings_pending_attendance_confirmation
    query = schools
      .joins(:bookings)
      .merge(Bookings::Booking.previous)
      .merge(Bookings::Booking.not_cancelled)
      .merge(Bookings::Booking.accepted)
      .merge(Bookings::Booking.attendance_unlogged)

    keyed_total(query, :bookings_pending_attendance_confirmation)
  end

  def schools
    Bookings::School.where(urn: school_urns)
  end

  def keyed_total(query, key)
    query
      .group('bookings_schools.urn')
      .count(:id)
      .reduce(zero_hash(key)) do |hash, (urn, count)|
        hash.tap { |h| h[urn] = { key => count } }
      end
  end

  def zero_hash(_key)
    school_urns.reduce({}) do |hash, urn|
      hash.tap { |h| h[urn] = Hash.new(0) }
    end
  end
end
