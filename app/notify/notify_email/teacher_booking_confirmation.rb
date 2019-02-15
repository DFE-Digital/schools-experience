class NotifyEmail::TeacherBookingConfirmation < Notify
  attr_accessor :candidate_name,
    :placement_start_date,
    :placement_finish_date,
    :school_experience_dashboard_link

  def initialize(
    to:,
    candidate_name:,
    placement_start_date:,
    placement_finish_date:,
    school_experience_dashboard_link:
  )

    self.candidate_name                   = candidate_name
    self.placement_start_date             = placement_start_date
    self.placement_finish_date            = placement_finish_date
    self.school_experience_dashboard_link = school_experience_dashboard_link

    super(to: to)
  end

private

  def template_id
    'bd76e50b-9943-49af-84bb-7e335efdf1d4'
  end

  def personalisation
    {
      candidate_name: candidate_name,
      placement_start_date: placement_start_date,
      placement_finish_date: placement_finish_date,
      school_experience_dashboard_link: school_experience_dashboard_link
    }
  end
end
