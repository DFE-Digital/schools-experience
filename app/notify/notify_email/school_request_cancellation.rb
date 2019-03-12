class NotifyEmail::SchoolRequestCancellation < Notify
  attr_accessor :school_admin_name,
    :school_name,
    :candidate_name,
    :placement_start_date,
    :placement_finish_date

  def initialize(
    to:,
    school_name:,
    school_admin_name:,
    candidate_name:,
    placement_start_date:,
    placement_finish_date:
  )

    self.school_admin_name     = school_admin_name
    self.school_name           = school_name
    self.candidate_name        = candidate_name
    self.placement_start_date  = placement_start_date
    self.placement_finish_date = placement_finish_date
    super(to: to)
  end

private

  def template_id
    '1d2b44bc-9d73-4839-b06b-41f35012c14d'
  end

  def personalisation
    {
      school_admin_name: school_admin_name,
      candidate_name: candidate_name,
      placement_start_date: placement_start_date,
      placement_finish_date: placement_finish_date,
      school_name: school_name
    }
  end
end
