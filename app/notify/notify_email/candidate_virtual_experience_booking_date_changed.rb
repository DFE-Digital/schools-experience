class NotifyEmail::CandidateVirtualExperienceBookingDateChanged < NotifyDespatchers::Email
  attr_accessor :school_name,
    :candidate_name,
    :placement_schedule,
    :school_start_time,
    :school_finish_time,
    :school_admin_email,
    :school_admin_telephone,
    :school_teacher_name,
    :school_teacher_email,
    :school_teacher_telephone,
    :candidate_instructions,
    :cancellation_url,
    :new_date,
    :old_date

  def initialize(
    to:,
    school_name:,
    candidate_name:,
    placement_schedule:,
    school_start_time:,
    school_finish_time:,
    school_admin_email:,
    school_admin_telephone:,
    school_teacher_name:,
    school_teacher_email:,
    school_teacher_telephone:,
    candidate_instructions:,
    cancellation_url:,
    new_date:,
    old_date:
  )

    self.school_name = school_name
    self.candidate_name = candidate_name
    self.placement_schedule = placement_schedule
    self.school_start_time = school_start_time
    self.school_finish_time = school_finish_time
    self.school_admin_email = school_admin_email
    self.school_admin_telephone = school_admin_telephone
    self.school_teacher_name = school_teacher_name
    self.school_teacher_email = school_teacher_email
    self.school_teacher_telephone = school_teacher_telephone
    self.candidate_instructions = candidate_instructions
    self.cancellation_url = cancellation_url
    self.new_date = new_date
    self.old_date = old_date

    super(to: to)
  end

  def self.from_booking(to, candidate_name, booking, cancellation_url, old_date)
    school = booking.bookings_school
    profile = school.profile

    new(
      to: to,
      school_name: school.name,
      candidate_name: candidate_name,
      placement_schedule: booking.placement_start_date_with_duration,
      school_start_time: profile.start_time,
      school_finish_time: profile.end_time,
      school_admin_email: profile.admin_contact_email,
      school_admin_telephone: profile.admin_contact_phone,
      school_teacher_name: booking.contact_name,
      school_teacher_email: booking.contact_email,
      school_teacher_telephone: booking.contact_number,
      candidate_instructions: booking.candidate_instructions,
      cancellation_url: cancellation_url,
      new_date: booking.date.to_formatted_s(:govuk),
      old_date: old_date
    )
  end

private

  def template_id
    '50a32920-fa3a-4294-b013-a6472e230cf8'
  end

  def personalisation
    {
      school_name: school_name,
      candidate_name: candidate_name,
      placement_schedule: placement_schedule,
      school_start_time: school_start_time,
      school_finish_time: school_finish_time,
      school_admin_email: school_admin_email,
      school_admin_telephone: school_admin_telephone,
      school_teacher_name: school_teacher_name,
      school_teacher_email: school_teacher_email,
      school_teacher_telephone: school_teacher_telephone,
      candidate_instructions: candidate_instructions,
      cancellation_url: cancellation_url,
      new_date: new_date,
      old_date: old_date
    }
  end
end
