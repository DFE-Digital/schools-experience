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
    'a9e737f1-198c-4060-b341-b9485527c377'
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
