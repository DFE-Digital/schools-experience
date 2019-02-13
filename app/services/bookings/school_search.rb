class Bookings::SchoolSearch
  attr_accessor :query, :point, :radius, :subjects, :phases, :max_fee, :requested_order

  AVAILABLE_ORDERS = [
    %w{distance Distance},
    %w{fee Fee}
  ].freeze

  def self.available_orders
    AVAILABLE_ORDERS.map
  end

  def initialize(query, location: nil, radius: 10, subjects: nil, phases: nil, max_fee: nil, requested_order: nil)
    self.query           = query
    self.point           = geolocate(location) if location.present?
    self.radius          = radius
    self.subjects        = subjects
    self.phases          = phases
    self.max_fee         = max_fee
    self.requested_order = requested_order
  end

  # Note, all of the scopes provided by +Bookings::School+ will not
  # amend the +ActiveRecord::Relation+ if no param is provided, meaning
  # they can be safely chained
  def results
    q = Bookings::School
      .close_to(
        @point,
        radius: @radius,
        calculate_distance: (@requested_order == 'distance')
      )
      .that_provide(@subjects)
      .at_phases(@phases)
      .costing_upto(@max_fee)
      .eager_load(:phases, :subjects, :school_type)
      .merge(Bookings::School.search(@query))
      .order(order_by(@requested_order))

    q.uniq
  end

private

  def geolocate(location)
    if (result = Geocoder.search(location)&.first)
      Bookings::School::GEOFACTORY.point(
        result.data.dig('lon'),
        result.data.dig('lat')
      )
    end
  end

  def order_by(requested_order)
    if (requested_order == 'distance') && @point.present?
      # note distance isn't actually an attribute of
      # Bookings::School so we can't use hash syntax
      # as Rails will complain
      'distance asc'
    elsif requested_order == 'fee'
      { fee: 'asc' }
    else
      nil
    end
  end
end
