class NotifyEmail::CandidateBookingConfirmation < NotifyDespatchers::Email
  attr_accessor :school_name,
    :candidate_name,
    :placement_schedule,
    :school_address,
    :school_start_time,
    :school_finish_time,
    :school_dress_code,
    :school_parking,
    :school_admin_email,
    :school_admin_telephone,
    :school_teacher_name,
    :school_teacher_email,
    :school_teacher_telephone,
    :placement_details,
    :candidate_instructions,
    :subject_name,
    :cancellation_url

  def initialize(
    to:,
    school_name:,
    candidate_name:,
    placement_schedule:,
    school_address:,
    school_start_time:,
    school_finish_time:,
    school_dress_code:,
    school_parking:,
    school_admin_email:,
    school_admin_telephone:,
    school_teacher_name:,
    school_teacher_email:,
    school_teacher_telephone:,
    placement_details:,
    candidate_instructions:,
    subject_name:,
    cancellation_url:
  )

    self.school_name = school_name
    self.candidate_name = candidate_name
    self.placement_schedule = placement_schedule
    self.school_address = school_address
    self.school_start_time = school_start_time
    self.school_finish_time = school_finish_time
    self.school_dress_code = school_dress_code
    self.school_parking = school_parking
    self.school_admin_email = school_admin_email
    self.school_admin_telephone = school_admin_telephone
    self.school_teacher_name = school_teacher_name
    self.school_teacher_email = school_teacher_email
    self.school_teacher_telephone = school_teacher_telephone
    self.placement_details = placement_details
    self.candidate_instructions = candidate_instructions
    self.subject_name = subject_name
    self.cancellation_url = cancellation_url

    super(to: to)
  end

  def self.from_booking(to, candidate_name, booking, cancellation_url)
    school = booking.bookings_school
    profile = school.profile

    new(
      to: to,
      school_name: school.name,
      candidate_name: candidate_name,
      placement_schedule: booking.placement_start_date_with_duration,
      school_address: [
        school.address_1,
        school.address_2,
        school.address_3,
        school.town,
        school.county,
        school.postcode
      ].reject(&:blank?).join(', '),
      school_start_time: profile.start_time,
      school_finish_time: profile.end_time,
      school_dress_code: [
        profile.dress_code,
        profile.dress_code_other_details,
      ].reject(&:blank?).join(', '),
      school_parking: [
        profile.parking_provided ? 'Yes' : 'No',
        profile.parking_details
      ].join(', '),
      school_admin_email: profile.admin_contact_email,
      school_admin_telephone: profile.admin_contact_phone,
      school_teacher_name: booking.contact_name,
      school_teacher_email: booking.contact_email,
      school_teacher_telephone: booking.contact_number,
      placement_details: profile.experience_details.to_s,
      candidate_instructions: booking.candidate_instructions,
      subject_name: booking.bookings_subject.name,
      cancellation_url: cancellation_url
    )
  end

private

  def template_id
    'f66aaa08-df33-4be6-95b6-7e1cf8595a2b'
  end

  def personalisation
    {
      school_name: school_name,
      candidate_name: candidate_name,
      placement_schedule: placement_schedule,
      school_address: school_address,
      school_start_time: school_start_time,
      school_finish_time: school_finish_time,
      school_dress_code: school_dress_code,
      school_parking: school_parking,
      school_admin_email: school_admin_email,
      school_admin_telephone: school_admin_telephone,
      school_teacher_name: school_teacher_name,
      school_teacher_email: school_teacher_email,
      school_teacher_telephone: school_teacher_telephone,
      placement_details: placement_details.to_s,
      candidate_instructions: candidate_instructions,
      subject_name: subject_name,
      cancellation_url: cancellation_url
    }
  end
end
