class NotifyEmail::CandidateBookingConfirmation < Notify
  attr_accessor :school_name,
    :candidate_name,
    :placement_start_date,
    :placement_finish_date,
    :school_start_time,
    :school_finish_time,
    :school_dress_code,
    :school_parking,
    :school_admin_name,
    :school_admin_email,
    :school_admin_telephone,
    :school_teacher_name,
    :school_teacher_email,
    :school_teacher_telephone,
    :placement_details,
    :placement_fee


  def initialize(
    to:,
    school_name:,
    candidate_name:,
    placement_start_date:,
    placement_finish_date:,
    school_start_time:,
    school_finish_time:,
    school_dress_code:,
    school_parking:,
    school_admin_name:,
    school_admin_email:,
    school_admin_telephone:,
    school_teacher_name:,
    school_teacher_email:,
    school_teacher_telephone:,
    placement_details:,
    placement_fee:
  )

    self.school_name = school_name
    self.candidate_name = candidate_name
    self.placement_start_date = placement_start_date
    self.placement_finish_date = placement_finish_date
    self.school_start_time = school_start_time
    self.school_finish_time = school_finish_time
    self.school_dress_code = school_dress_code
    self.school_parking = school_parking
    self.school_admin_name = school_admin_name
    self.school_admin_email = school_admin_email
    self.school_admin_telephone = school_admin_telephone
    self.school_teacher_name = school_teacher_name
    self.school_teacher_email = school_teacher_email
    self.school_teacher_telephone = school_teacher_telephone
    self.placement_details = placement_details
    self.placement_fee = placement_fee

    super(to: to)
  end

private

  def template_id
    '482c3495-8e99-46f0-93d4-b88e31879565'
  end

  def personalisation
    {
      school_name: school_name,
      candidate_name: candidate_name,
      placement_start_date: placement_start_date,
      placement_finish_date: placement_finish_date,
      school_start_time: school_start_time,
      school_finish_time: school_finish_time,
      school_dress_code: school_dress_code,
      school_parking: school_parking,
      school_admin_name: school_admin_name,
      school_admin_email: school_admin_email,
      school_admin_telephone: school_admin_telephone,
      school_teacher_name: school_teacher_name,
      school_teacher_email: school_teacher_email,
      school_teacher_telephone: school_teacher_telephone,
      placement_details: placement_details,
      placement_fee: placement_fee
    }
  end
end
