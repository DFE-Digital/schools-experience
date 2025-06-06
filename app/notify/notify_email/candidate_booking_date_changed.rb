class NotifyEmail::CandidateBookingDateChanged < NotifyDespatchers::Email
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
    :cancellation_url,
    :new_date,
    :old_date

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
    cancellation_url:,
    new_date:,
    old_date:
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
    self.placement_details = placement_details.to_s
    self.candidate_instructions = candidate_instructions
    self.subject_name = subject_name
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
      placement_details: profile.experience_details,
      candidate_instructions: booking.candidate_instructions,
      subject_name: booking.bookings_subject.name,
      cancellation_url: cancellation_url,
      new_date: booking.date.to_formatted_s(:govuk),
      old_date: old_date
    )
  end

private

  def template_id
    '3c1fd380-db1c-4efb-8e98-f3a0ef3e2661'
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
      placement_details: placement_details,
      candidate_instructions: candidate_instructions,
      subject_name: subject_name,
      cancellation_url: cancellation_url,
      new_date: new_date,
      old_date: old_date
    }
  end
end
