class NotifyEmail::SchoolBookingCancellation < Notify
  attr_accessor :school_admin_name,
    :school_name,
    :candidate_name,
    :placement_start_date_with_duration

  def initialize(
    to:,
    school_name:,
    school_admin_name:,
    candidate_name:,
    placement_start_date_with_duration:
  )

    self.school_admin_name                   = school_admin_name
    self.school_name                         = school_name
    self.candidate_name                      = candidate_name
    self.placement_start_date_with_duration  = placement_start_date_with_duration
    super(to: to)
  end

private

  def template_id
    '1e0073e2-1334-4a50-a386-acc57f380e14'
  end

  def personalisation
    {
      school_admin_name: school_admin_name,
      candidate_name: candidate_name,
      placement_start_date_with_duration: placement_start_date_with_duration,
      school_name: school_name
    }
  end
end
