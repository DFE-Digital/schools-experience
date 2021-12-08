class NotifyEmail::TeacherBookingCancellation < NotifyDespatchers::Email
  attr_accessor :school_teacher_name,
    :candidate_name,
    :school_name,
    :placement_start_date,
    :placement_finish_date,
    :placement_cancellation_reason

  def initialize(
    to:,
    school_teacher_name:,
    school_name:,
    candidate_name:,
    placement_start_date:,
    placement_finish_date:,
    placement_cancellation_reason:
  )

    self.school_teacher_name           = school_teacher_name
    self.school_name                   = school_name
    self.candidate_name                = candidate_name
    self.placement_start_date          = placement_start_date
    self.placement_finish_date         = placement_finish_date
    self.placement_cancellation_reason = placement_cancellation_reason

    super(to: to)
  end

private

  def template_id
    '7445560b-46da-4c23-9017-e8d45b2a6c84'
  end

  def personalisation
    {
      school_teacher_name: school_teacher_name,
      school_name: school_name,
      candidate_name: candidate_name,
      placement_start_date: placement_start_date,
      placement_finish_date: placement_finish_date,
      placement_cancellation_reason: placement_cancellation_reason
    }
  end
end
