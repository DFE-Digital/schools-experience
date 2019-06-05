class NotifyEmail::CandidateBookingConfirmation < Notify
  attr_accessor :school_name,
    :candidate_name,
    :placement_start_date,
    :placement_finish_date,
    :school_address,
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
    school_address:,
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
    self.school_address = school_address
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

  def self.from_booking(to, booking)
    school = booking.bookings_school
    placement_request = booking.bookings_placement_request
    candidate = placement_request.candidate
    profile = school.profile

    new(
      to: to,
      school_name: school.name,
      candidate_name: [candidate.firstname, candidate.lastname].join(' '),
      placement_start_date: booking.date,
      placement_finish_date: 'FIXME',
      school_address: [
        school.address_1,
        school.address_2,
        school.address_3,
        school.town,
        school.county,
        school.postcode
      ].join(', '),
      school_start_time: profile.start_time,
      school_finish_time: profile.end_time,
      school_dress_code: [
        profile.dress_code,
        profile.dress_code_other_details,
      ].join(', '),
      school_parking: [
        profile.parking_provided ? 'Yes' : 'No',
        profile.parking_details
      ].join(', '),
      school_admin_name: profile.admin_contact_full_name,
      school_admin_email: profile.admin_contact_email,
      school_admin_telephone: profile.admin_contact_phone,
      school_teacher_name: booking.contact_name,
      school_teacher_email: booking.contact_email,
      school_teacher_telephone: booking.contact_number,
      placement_details: booking.placement_details,
      placement_fee: 'REMOVE' # FIXME
    )
  end

private

  def template_id
    '29ed44bd-dc79-4fb3-bf8e-6e0ff18365b3'
  end

  def personalisation
    {
      school_name: school_name,
      candidate_name: candidate_name,
      placement_start_date: placement_start_date,
      placement_finish_date: placement_finish_date,
      school_address: school_address,
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
